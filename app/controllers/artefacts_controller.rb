class ArtefactsController < ApplicationController
  before_filter :find_artefact, :only => [:show, :edit]
  before_filter :build_artefact, :only => [:new, :create]
  before_filter :tag_collection, :except => [:show]

  respond_to :html, :json

  def index
    @artefacts = Artefact.order_by([[:name, :asc]])

    @section = params[:section] || "all"
    if @section != "all"
      @artefacts = @artefacts.where(tag_ids: params[:section])
    end
    respond_with @artefacts, @tag_collection
  end

  def show
    respond_with @artefact do |format|
      format.html { redirect_to @artefact.admin_url }
    end
  end

  def new
    redirect_to_show_if_need_met
  end

  def edit
    @actions = build_actions
  end

  def create
    @artefact.save_as action_user
    respond_with @artefact, location: @artefact.admin_url(params.slice(:return_to))
  end

  # NB: We are departing from usual rails conventions here. PUTing a resource
  # will create it if it doesn't exist, rather than the usual 404.
  def update
    begin
      @artefact = Artefact.from_param(params[:id])
      status_to_use = 200
    rescue Mongoid::Errors::DocumentNotFound
      @artefact = Artefact.new(slug: params[:id])
      status_to_use = 201
    end

    parameters_to_use = extract_parameters(params)

    if attempting_to_change_owning_app?(parameters_to_use)
      render(
        text: "This artefact already belongs to the '#{@artefact.owning_app}' app",
        status: 409
      )
      return
    end

    saved = @artefact.update_attributes_as(action_user, parameters_to_use)
    flash[:notice] = saved ? 'Panopticon item updated' : 'Failed to save item'

    if saved && params[:commit] == 'Save and continue editing'
      redirect_to edit_artefact_path(@artefact)
    else
      @actions = build_actions
      respond_with @artefact, status: status_to_use do |format|
        format.json { render json: @artefact.to_json, status: status_to_use }
      end
    end
  end

  def destroy
    @artefact = Artefact.from_param(params[:id])
    @artefact.update_attributes_as(action_user, state: "archived")
    respond_with(@artefact) do |format|
      format.html { head 200 }
    end
  end

  private

    def tag_collection
      @tag_collection = TagRepository.load_all(:tag_type => 'section').asc(:title).to_a

      title_counts = Hash.new(0)
      @tag_collection.each do |tag|
        title_counts[tag.title] += 1
      end

      @tag_collection.each do |tag|
        tag.uniquely_named = title_counts[tag.title] < 2
      end
    end

    def attempting_to_change_owning_app?(parameters_to_use)
      @artefact.persisted? &&
        parameters_to_use.include?('owning_app') &&
        parameters_to_use['owning_app'] != @artefact.owning_app
    end

    def redirect_to_show_if_need_met
      if params[:artefact] && params[:artefact][:need_id]
        artefact = Artefact.where(need_id: params[:artefact][:need_id]).first
        redirect_to artefact if artefact
      end
    end

    def find_artefact
      @artefact = Artefact.from_param(params[:id])
    end

    def build_artefact
      @artefact = Artefact.new(extract_parameters(params))
    end

    def extract_parameters(params)
      fields_to_update = Artefact.fields.keys + ['sections', 'primary_section']

      # TODO: Remove this variance
      parameters_to_use = params[:artefact] || params.slice(*fields_to_update)

      # Partly for legacy reasons, the API can receive live=true
      if live_param = parameters_to_use[:live]
        if ["true", true, "1"].include?(live_param)
          parameters_to_use[:state] = "live"
        end
      end

      # Strip out the empty submit option for sections
      ['sections', 'legacy_source_ids'].each do |param|
        param_value = parameters_to_use[param]
        param_value.reject!(&:blank?) if param_value
      end
      parameters_to_use
    end

    def action_user
      # The user to associate with actions
      # Currently this returns nil for the API user: this should go away once
      # we have real user authentication for API requests
      action_user = current_user.is_a?(User) ? current_user : nil
    end

    def build_actions
      # Construct a list of actions, with embedded diffs
      # The reason for appending the nil is so that the initial action is
      # included: the DiffEnabledAction class handles the case where the previous
      # action does not exist
      reverse_actions = @artefact.actions.reverse
      (reverse_actions + [nil]).each_cons(2).map { |action, previous|
        DiffEnabledAction.new(action, previous)
      }
    end
end
