class ArtefactsController < ApplicationController
  before_filter :redirect_to_show_if_need_met, :only => :new
  before_filter :find_artefact, :only => [:show, :edit, :update]
  before_filter :build_artefact, :only => [:new, :create]
  before_filter :mark_removed_records_for_destruction, :only => :update
  
  skip_before_filter :authenticate_user!, :if => lambda { |c|
    c.action_name == 'show' && c.request.format.json?
  }

  respond_to :html, :json


  def index
    @artefacts = Artefact.order(:name).all
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
  rescue => e
    logger.info(e + " " + e.backtrace.join("\n"))
    raise
  end

  def update
    @artefact.update_attributes!(params[:artefact] || params.slice(*Artefact.attribute_names))

    if params[:commit] == "Save and continue editing"
      redirect_to edit_artefact_path(@artefact), :notice => 'Panopticon item updated'
    else
      respond_with @artefact
    end
  end

  private
    def redirect_to_show_if_need_met
      artefact = Artefact.find_by_need_id params[:artefact][:need_id]
      redirect_to artefact if artefact.present?
    end

    def find_artefact
      @artefact = Artefact.from_param(params[:id])
    end

    def build_artefact
      @artefact = Artefact.new(params[:artefact] || params.slice(*Artefact.attribute_names))
    rescue => e
      logger.info(e + " " + e.backtrace.join("\n"))
      raise
    end
    
    # TODO: Convert this to a presenter

    def mark_removed_records_for_destruction
      [:related_artefacts].each do |association|
        reflection = Artefact.reflect_on_association association
        through_association, foreign_key = reflection.through_reflection.name, reflection.foreign_key

        mark_associated_records_for_destruction through_association,
          :if => -> attributes { attributes[foreign_key].blank? }
      end
    end

    def mark_associated_records_for_destruction(association, options)
      primary_key = Artefact.reflect_on_association(association).active_record_primary_key

      return unless params[:artefact] && params[:artefact][:"#{association}_attributes"]
      params[:artefact][:"#{association}_attributes"].each_value do |attributes|
        attributes[:_destroy] = attributes[primary_key].present? && options[:if].call(attributes)
      end
    end
end
