class ArtefactsController < ApplicationController
  before_filter :redirect_to_show_if_need_met, :only => :new
  before_filter :find_artefact, :only => [:show, :edit, :update]
  before_filter :build_artefact, :only => [:new, :create]

  respond_to :html, :json

  def index
    @artefacts = Artefact.order_by([[:name, :asc]]).all
    respond_with @artefacts
  end

  def show
    respond_with @artefact do |format|
      format.html { redirect_to @artefact.admin_url }
    end
  end

  def new
  end

  def edit
  end

  def create
    @artefact.save
    location = @artefact.admin_url
    location += '?return_to=' + params[:return_to] if params[:return_to]
    respond_with @artefact, location: location
  end

  def update
    fields_to_update = Artefact.fields.keys + ['sections']
    parameters_to_use = params[:artefact] || params.slice(*fields_to_update)

    # Strip out the empty submit option for sections
    ['sections'].each do |param|
      param_value = parameters_to_use[param]
      param_value.reject! &:blank? unless param_value.nil?
    end

    saved = @artefact.update_attributes(parameters_to_use)
    flash[:notice] = saved ? 'Panopticon item updated' : 'Failed to save item'

    if saved and params[:commit] == 'Save and continue editing'
      redirect_to edit_artefact_path(@artefact)
    else
      respond_with @artefact
    end
  end

  private
    def redirect_to_show_if_need_met
      if params[:artefact] and params[:artefact][:need_id]
        artefact = Artefact.where(need_id: params[:artefact][:need_id]).first
        redirect_to artefact if artefact
      end
    end

    def find_artefact
      @artefact = Artefact.from_param(params[:id])
    end

    def build_artefact
      @artefact = Artefact.new(params[:artefact] || params.slice(*Artefact.fields.keys))
    end
end
