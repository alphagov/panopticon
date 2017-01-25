class ArtefactsController < ApplicationController
  before_filter :find_artefact, :except => %i(index new)
  helper_method :sort_column, :sort_direction
  wrap_parameters include: ParameterExtractor::ALLOWED_FIELD_NAMES

  respond_to :html

  ITEMS_PER_PAGE = 100

  def index
    @filters = params.slice(:kind, :state, :search, :owned_by)

    scope = artefact_scope.without(:actions)
    scope = FilteredScope.new(scope, @filters).scope
    scope = scope.order_by([[sort_column, sort_direction]])

    @artefacts = scope.page(params[:page]).per(ITEMS_PER_PAGE)
    respond_with @artefacts
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
    @publisher_edition_url = publisher_edition_url(@artefact)

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

  def update
    saved = @artefact.update_attributes_as current_user, extract_parameters(params)

    if saved
      flash[:success] = 'Panopticon item updated'
    else
      flash[:danger] = 'Failed to save item'
    end

    continue_editing = (params[:commit] == 'Save and continue editing')

    if saved && (continue_editing || (@artefact.owning_app != OwningApp::PUBLISHER))
      redirect_to edit_artefact_path(@artefact)
    else
      @actions = build_actions
      respond_with @artefact, status: 200
    end
  end

private

  def publisher_edition_url(artefact)
    edition = Edition.where(panopticon_id: artefact.id).order_by(version_number: :desc).first

    if edition
      Plek.find('publisher') + "/editions/#{edition.id}/unpublish"
    else
      admin_url_for_edition(artefact)
    end
  end

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
end
