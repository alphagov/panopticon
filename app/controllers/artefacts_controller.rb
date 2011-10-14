class ArtefactsController < ApplicationController
  before_filter :redirect_to_show_if_need_met, :only => :new
  before_filter :find_artefact, :only => [ :show, :edit, :update ]
  before_filter :build_artefact, :only => [ :new, :create ]

  def show
    respond_to do |format|
      format.js { render :json => @artefact }
      format.html { redirect_to @artefact.admin_url }
    end
  end

  def new
  end

  def edit
  end

  def create
    @artefact.save!
    relate_artefacts @artefact, params[:artefact]
    destination = @artefact.admin_url
    destination += '?return_to=' + params[:return_to] if params[:return_to]
    redirect_to destination
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end

  def update
    update_artefact @artefact, params[:artefact]
    relate_artefacts @artefact, params[:artefact]
    @artefact.save!
    redirect_to @artefact
  rescue ActiveRecord::RecordInvalid
    render :action => :edit
  end

  def build_artefact
    @artefact = Artefact.new
    update_artefact @artefact, params[:artefact]
  end
  private :build_artefact
  hide_action :build_artefact

  def find_artefact
    # FIXME: A hack until the Publisher has panopticon ids for every article
    @artefact = Artefact.find_by_slug params[:id]
    @artefact ||= Artefact.find params[:id]
  end
  private :find_artefact
  hide_action :find_artefact

  def update_artefact artefact, attributes
    artefact.name = attributes[:name]
    artefact.slug = attributes[:slug]
    artefact.tags = attributes[:tags]
    artefact.section = attributes[:section]
    artefact.department = attributes[:department]
    if artefact.new_record?
      artefact.kind = attributes[:kind]
      artefact.owning_app = attributes[:owning_app]
      artefact.need_id = attributes[:need_id]
    end
    artefact.audience_ids = attributes[:audience_ids] if attributes.key? :audience_ids
    artefact.normalise
  end

  def relate_artefacts artefact, attributes
    Artefact::MAXIMUM_RELATED_ITEMS.times do |n|
      artefact.send "related_item_#{n}=", attributes["related_item_#{n}"]
    end
  end

  def redirect_to_show_if_need_met
    artefact = Artefact.find_by_need_id params[:artefact][:need_id]
    redirect_to artefact if artefact.present?
  end
end
