class ArtefactsController < ApplicationController
  before_filter :find_artefact, :only => [:show, :edit, :history, :withdraw]
  before_filter :build_artefact, :only => [:create]
  before_filter :find_or_build_artefact, :only => [:update]
  before_filter :register_url_with_publishing_api, :only => [:create, :update]
  helper_method :sort_column, :sort_direction
  wrap_parameters include: ParameterExtractor::ALLOWED_FIELD_NAMES

  respond_to :html, :json

  ITEMS_PER_PAGE = 100

  def index
    @filters = params.slice(:section, :specialist_sector, :kind, :state, :search, :owned_by)

    scope = artefact_scope.without(:actions)
    scope = FilteredScope.new(scope, @filters).scope
    scope = scope.order_by([[sort_column, sort_direction]])

    @artefacts = scope.page(params[:page]).per(ITEMS_PER_PAGE)
    respond_with @artefacts
  end

  def search_relatable_items
    respond_with RelatableItems.new(params).relatable_items.to_json
  end

  def show
    respond_with @artefact do |format|
      format.html { redirect_to admin_url_for_edition(@artefact) }
    end
  end

  def history
    @actions = build_actions
  end

  def withdraw
    if @artefact.archived? || @artefact.owning_app != OwningApp::PUBLISHER
      redirect_to root_path
    end
  end

  def new
    @artefact = Artefact.new
    redirect_to_show_if_need_met
  end

  def edit
  end

  def create
    if @artefact.owning_app == OwningApp::PUBLISHER
      @artefact.content_id = SecureRandom.uuid
    end

    @artefact.save_as current_user
    continue_editing = (params[:commit] == 'Save and continue editing')

    if continue_editing || @artefact.owning_app != OwningApp::PUBLISHER
      location = edit_artefact_path(@artefact.id)
    else
      location = admin_url_for_edition(@artefact, params.slice(:return_to))
    end

    respond_with @artefact, location: location
  end

  # NB: We are departing from usual rails conventions here. PUTing a resource
  # will create it if it doesn't exist, rather than the usual 404.
  def update
    status_to_use = @artefact.new_record? ? 201 : 200

    parameters_to_use = extract_parameters(params)

    saved = @artefact.update_attributes_as(current_user, parameters_to_use)

    if saved
      flash[:success] = 'Panopticon item updated'
    else
      flash[:danger] = 'Failed to save item'
    end

    @actions = build_actions

    if saved && @artefact.content_id
      Rails.application.publishing_api_v2.patch_links(
        @artefact.content_id,
        links: {
          ordered_related_items: @artefact.related_artefacts.map(&:content_id).compact
        }
      )
    end

    respond_with @artefact, status: status_to_use do |format|
      format.html do
        continue_editing = (params[:commit] == 'Save and continue editing')

        if saved && (continue_editing || (@artefact.owning_app != OwningApp::PUBLISHER))
          redirect_to edit_artefact_path(@artefact)
        else
          respond_with @artefact, status: status_to_use
        end
      end

      format.json do
        if saved
          render json: @artefact.to_json, status: status_to_use
        else
          render json: { "errors" => @artefact.errors.full_messages }, status: 422
        end
      end
    end
  end

  def destroy
    @artefact = Artefact.from_param(params[:id])
    redirect_url = params[:artefact] && params[:artefact][:redirect_url]
    redirect_url.sub!(%r{^https?://(www\.)?gov\.uk/}, "/") if redirect_url

    if @artefact.update_attributes_as(
      current_user,
      state: "archived",
      redirect_url: redirect_url
    )
      RemoveFromSearch.call(@artefact.slug)
      respond_with(@artefact) do |format|
        format.json { head 200 }
        format.html { redirect_to artefacts_path }
      end
    else
      flash[:danger] = @artefact.errors.full_messages.to_sentence
      redirect_to withdraw_artefact_path(@artefact)
    end
  end

  private

    def admin_url_for_edition(artefact, options = {})
      [
        "#{Plek.current.find(artefact.owning_app)}/admin/publications/#{artefact.id}",
        options.to_query
      ].reject(&:blank?).join("?")
    end

    def artefact_scope
      # This is here so that we can stub this out a bit more easily in the
      # functional tests.
      Artefact
    end

    def redirect_to_show_if_need_met
      if params[:artefact] && params[:artefact][:need_id]
        artefact = Artefact.any_in(need_ids: [params[:artefact][:need_id]]).first
        redirect_to artefact if artefact
      end
    end

    def find_artefact
      @artefact = Artefact.from_param(params[:id])
    end

    def find_or_build_artefact
      find_artefact
    rescue Mongoid::Errors::DocumentNotFound
      @artefact = Artefact.new(slug: params[:id])
    end

    def build_artefact
      @artefact = Artefact.new(extract_parameters(params))
    end

    def extract_parameters(params)
      ParameterExtractor.new(params).extract
    end

    def build_actions
      # Construct a list of actions, with embedded diffs
      # The reason for appending the nil is so that the initial action is
      # included: the DiffEnabledAction class handles the case where the
      # previous action does not exist
      reverse_actions = @artefact.actions.reverse
      (reverse_actions + [nil]).each_cons(2).map { |action, previous|
        DiffEnabledAction.new(action, previous)
      }
    end

    def sort_column
      Artefact.fields.keys.include?(params[:sort]) ? params[:sort] : :name
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : :asc
    end

    def register_url_with_publishing_api
      parameters_to_use = extract_parameters(params)

      # publishing api url-arbitration would reject this request,
      # therefore rely on our model validation to make the error messaging better
      return if @artefact.slug.blank? || parameters_to_use['owning_app'].blank?

      Rails.application.publishing_api.put_path("/#{@artefact.slug}", "publishing_app" => parameters_to_use['owning_app'])
    rescue GdsApi::HTTPClientError => e
      message = ""
      if e.error_details["errors"]
        e.error_details["errors"].each do |field, errors|
          errors.each do |error|
            message << "#{field.humanize} #{error}\n"
          end
        end
      else
        message = e.message
      end

      render text: message, status: 409
    end
end
