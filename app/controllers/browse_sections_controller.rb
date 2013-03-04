class BrowseSectionsController < ApplicationController
  before_filter :require_permission
  before_filter :find_section, only: [:edit, :update]

  def index
    @sections = Tag.where(tag_type: "section").order_by([:tag_id, :asc])
  end

  def edit
  end

  def update
    clean_params = params[:section].delete_if { |k,v| k == "tag_id" }
    if @section.update_attributes(clean_params)
      redirect_to browse_sections_path, notice: "Updated #{@section.title} browse section"
    else
      flash[:error] = "Failed to save"
      render :edit
    end
  end

  private
    def require_permission
      authorise_user!("Browse section admin")
    end

    def find_section
      @section = Tag.find(params[:id])
    end
end
