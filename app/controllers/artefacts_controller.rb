class ArtefactsController < ApplicationController
  before_filter :redirect_to_show_if_need_met, :only => :new
  before_filter :find_artefact, :only => [:show, :edit, :update]
  before_filter :build_artefact, :only => [:new, :create]
  before_filter :mark_removed_records_for_destruction, :only => :update

  def show
    respond_to do |format|
      format.js do # TODO use format.json
        # TODO extract presenter
        render :json =>
          @artefact.as_json(
            :include => {
              :audiences      => {},
              :related_items  => { :include => :artefact }, # TODO use :related_artefacts => {}
              :contacts       => {}
            }
          )
      end

      format.html { redirect_to @artefact.admin_url }
    end
  end

  def new
  end

  def edit
  end

  def create
    if @artefact.save
      destination = @artefact.admin_url
      destination += '?return_to=' + params[:return_to] if params[:return_to]
      redirect_to destination
    else
      render :new
    end
  end

  def update
    if @artefact.update_attributes(params[:artefact])
      redirect_to @artefact
    else
      render :edit
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
      @artefact = Artefact.new(params[:artefact])
    end

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

      params[:artefact][:"#{association}_attributes"].each_value do |attributes|
        attributes[:_destroy] = attributes[primary_key].present? && options[:if].call(attributes)
      end
    end
end
