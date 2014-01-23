class SectionModulesController < ApplicationController
  before_filter :require_permission
  
  def index
    @section_modules = SectionModule.all
  end
  
  def new
    @section_module = SectionModule.new
  end
  
  def edit
    @section_module = SectionModule.find(params[:id])
  end
  
  def create
    @section_module = SectionModule.new(params[:section_module])
    unless params[:section_module][:image].blank?
      image = params[:section_module].delete(:image)
      @section_module.image = image
    end
    saved = @section_module.save
    flash[:notice] = saved ? 'Module created!' : 'Failed to save module'
    redirect_to section_modules_path     
  end
  
  def update
    @section_module = SectionModule.find(params[:id])
    if params[:section_module][:remove_image]
      @section_module.image_id = nil
    end
    unless params[:section_module][:image].blank?
      image = params[:section_module].delete(:image)
      @section_module.image = image
    end
    @section_module.update_attributes!(params[:section_module])
    saved = @section_module.save
    flash[:notice] = saved ? 'Module updated!' : 'Failed to save module'
    render "section_modules/edit"
  end
  
  private
    
    def require_permission
      authorise_user!("Manage sections")
    end
  
end
