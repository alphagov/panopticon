class ArtefactsController < ApplicationController
  before_filter :find_artefact, :only => [:show, :edit, :history, :archive]
  before_filter :build_artefact, :only => [:new, :create]
  before_filter :tag_collection, :except => [:show]
  before_filter :tags_by_kind, :except => [:show]
  before_filter :get_roles, :only => [:new, :edit]
  before_filter :get_node_list, :only => [:new, :edit]
  before_filter :get_people_list, :only => [:new, :edit]
  before_filter :get_organization_list, :only => [:new, :edit]
  before_filter :get_keywords, :only => [:new, :edit, :create, :update]
  before_filter :get_teams, :only => [:new, :edit, :create, :update]
  before_filter :disable_unnecessary_features
  helper_method :relatable_items
  helper_method :sort_column, :sort_direction

  respond_to :html, :json

  ITEMS_PER_PAGE = 100

  def index
    @filters = params.slice(:section, :kind, :state, :search)
    @scope = apply_filters(artefact_scope, @filters)

    @scope = @scope.order_by([[sort_column, sort_direction]])
    @artefacts = @scope.page(params[:page]).per(ITEMS_PER_PAGE)
    respond_with @artefacts, @tag_collection
  end

  def show
    respond_with @artefact do |format|
      format.html { redirect_to admin_url_for_edition(@artefact) }
    end
  end

  def history
    @actions = build_actions
  end

  def archive

  end

  def new
    redirect_to_show_if_need_met
    # Set default author to current user
    # We have to do it this way because https://github.com/justinfrench/formtastic/wiki/Deprecation-of-%3Aselected-option
    @artefact.author = current_user.profile
  end

  def edit
  end

  def create
    @artefact.save_as current_user
    continue_editing = (params[:commit] == 'Save and continue editing')
    if continue_editing || @artefact.owning_app != "publisher"
      location = edit_artefact_path(@artefact.id)
    else
      location = admin_url_for_edition(@artefact, params.slice(:return_to))
    end
    respond_with @artefact, location: location
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
        text: "This artefact already belongs to the
               '#{@artefact.owning_app}' app",
        status: 409
      )
      return
    end

    saved = @artefact.update_attributes_as(current_user, parameters_to_use)
    flash[:notice] = saved ? 'Panopticon item updated' : 'Failed to save item'

    @actions = build_actions
    respond_with @artefact, status: status_to_use do |format|
      format.html do
        continue_editing = (params[:commit] == 'Save and continue editing')
        if saved && (continue_editing || (@artefact.owning_app != "publisher"))
          redirect_to edit_artefact_path(@artefact)
        else
          respond_with @artefact, status: status_to_use
        end
      end
      format.json do
        if saved
          render json: @artefact.to_json, status: status_to_use
        else
          render json: {"errors" => @artefact.errors.full_messages}, status: 422
        end
      end
    end
  end

  def destroy
    @artefact = Artefact.from_param(params[:id])
    @artefact.update_attributes_as(current_user, state: "archived")
    respond_with(@artefact) do |format|
      format.json { head 200 }
      format.html { redirect_to artefacts_path }
    end
  end

  private

    def disable_unnecessary_features
      unless Rails.env.test?
        @disable_business_content = true
        @disable_extra_fonts = true
        @disable_needs = true
        @disable_writing_team = true
        @disable_legacy_sources = true
        @disable_description = true
      end
    end

    def get_roles
      @roles = Tag.where(:tag_type => 'role').order_by([:title, :desc])
      role = params[:role] || "odi"
      @artefact.roles = [role] if @artefact.roles.empty?
    end

    def get_node_list
      @nodes = Artefact.where(:kind => "node").order_by(:name.asc).to_a.map {|p| [p.name, p.slug]}
    end

    def get_people_list
      @people = Artefact.where(:kind => "person", :state => "live").order_by(:name.asc).to_a.map {|p| [p.name, p.slug]}
    end

    def get_organization_list
      @organizations = Artefact.where(:kind => "organization").order_by(:name.asc).to_a.map {|p| [p.name, p.slug]}
    end

    def get_keywords
      @keywords = @artefact.keywords.map { |k| k.title }.join(", ") if @artefact
      @available_keywords = Tag.where(tag_type: "keyword").map { |k| k.title }
    end

    def get_teams
      @teams = @artefact.team.map { |k| k.title }.join(", ") if @artefact
      @available_teams = Tag.where(tag_type: "team").map { |k| k.title }
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

    def apply_filters(scope, filters)
      [:section].each do |tag_type|
        if filters[tag_type].present?
          scope = scope.with_parent_tag(tag_type, filters[tag_type])
        end
      end

      if filters[:state].present? && Artefact::STATES.include?(filters[:state])
        scope = scope.in_state(filters[:state])
      end

      if filters[:kind].present? && Artefact::FORMATS.include?(filters[:kind])
        scope = scope.of_kind(filters[:kind])
      end

      if filters[:search].present?
        scope = scope.matching_query(filters[:search])
      end

      scope
    end

    def tag_collection
      @tag_collection = Tag.where(:tag_type => 'section')
                                     .asc(:title).to_a

      title_counts = Hash.new(0)
      @tag_collection.each do |tag|
        title_counts[tag.title] += 1
      end

      @tag_collection.each do |tag|
        tag.uniquely_named = title_counts[tag.title] < 2
      end
    end

    def tags_by_kind
      @tags = {}
      Artefact.category_tags.each do |tag|
        tags = Tag.where(:tag_type => tag).to_a
        @tags[tag] = tags
      end
    end

    def relatable_items
      @relatable_items ||= Artefact.relatable_items.to_a
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
      # Map the actual tag ids for roles, as the ID is submitted
      unless params[:artefact].nil?
        if params[:artefact][:keywords].is_a?(String)
          params[:artefact][:keywords] = params[:artefact][:keywords].split(",").map(&:strip)
        end
        if params[:artefact][:team].is_a?(String)
          params[:artefact][:team] = params[:artefact][:team].split(",").map(&:strip)
        end

        create_keywords(params) if params[:artefact][:keywords]
        map_teams!(params) if params[:artefact][:team]
        map_roles!(params)
      end

      fields_to_update = Artefact.fields.keys + ['sections', 'primary_section']

      # TODO: Remove this variance
      parameters_to_use = params[:artefact] || params.slice(*fields_to_update)

      # Partly for legacy reasons, the API can receive live=true
      if live_param = parameters_to_use[:live]
        if ["true", true, "1"].include?(live_param)
          parameters_to_use[:state] = "live"
        end
      end

      # Convert nil tag fields to empty arrays if they're present
      Artefact.tag_types.each do |tag_type|
        if parameters_to_use.has_key?(tag_type)
          parameters_to_use[tag_type] ||= []
        end
      end

      # Strip out the empty submit option for sections
      ['sections', 'legacy_source_ids', 'person', 'timed_item', 'asset', 'article', 'organization', 'team', 'event', 'roles', 'featured'].each do |param|
        param_value = parameters_to_use[param]
        param_value.reject!(&:blank?) if param_value
      end
      parameters_to_use
    end

    def map_roles!(params)
      params[:artefact][:roles].map! { |r| Tag.find(r).tag_id rescue nil } unless params[:artefact][:roles].nil?
    end

    def create_keywords(params)
      params[:artefact][:keywords].each { |k| Tag.find_or_create_by(tag_id: k.parameterize, title: k, tag_type: "keyword") }
      params[:artefact][:keywords].map! { |k| k.parameterize }
    end

    def map_teams!(params)
      params[:artefact][:team].map! { |t| Tag.where(title: t, tag_type: "team").first.tag_id rescue nil }
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
