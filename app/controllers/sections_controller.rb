class SectionsController < ApplicationController
  before_filter :require_manage_permission, :only => [:index, :edit, :update]
  before_filter :require_create_permission, :only => [:new, :create]
  
  def index
    @sections = Section.all
  end
  
  def new
    @section = Section.new
  end
  
  def edit
    @section = Section.find(params[:id])
  end
  
  def create
    params[:section][:modules].reject! { |m| m.empty? }
    @section = Section.new(params[:section])
    unless params[:section][:hero_image].blank?
      hero_image = params[:section].delete(:hero_image)
      @section.hero_image = hero_image
    end
    saved = @section.save
    flash[:notice] = saved ? 'Section created!' : 'Failed to save section'
    redirect_to sections_path
  end
  
  def update
    @section = Section.find(params[:id])
    if params[:section][:remove_image]
      @section.hero_image_id = nil
    end
    unless params[:section][:hero_image_id].blank?
      hero_image_id = params[:section].delete(:hero_image)
      @section.hero_image = hero_image
    end
    params[:section][:modules].reject! { |m| m.empty? }
    @section.update_attributes!(params[:section])
    saved = @section.save
    flash[:notice] = saved ? 'Section updated!' : 'Failed to save section'
    render "sections/edit"
  end
  
  private
  
    def require_manage_permission
      authorise_user!("Manage sections")
    end
    
    def require_create_permission
      authorise_user!("Create sections")
    end  
  
end