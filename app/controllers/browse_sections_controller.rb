class BrowseSectionsController < ApplicationController
  before_filter :require_permission
  before_filter :find_section, only: [:edit, :update]

  helper_method :artefacts_in_section

  def index
    @sections = Tag.where(tag_type: "section").order_by([:tag_id, :asc])
  end

  def edit
  end

  def update
    clean_params = params[:section].delete_if { |k,v| k == "tag_id" }
    if params[:curated_list]
      @curated_list.update_attributes(params[:curated_list])
    end

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
      if @section.has_parent?
        tag_id_as_curated_list_slug = @section.tag_id.gsub(%r{/}, "-")
        existing_list = CuratedList.where(slug: tag_id_as_curated_list_slug).first
        if existing_list.present?
          @curated_list = existing_list
        else
          @curated_list = CuratedList.new(slug: tag_id_as_curated_list_slug)
        end
      end
    end

    def artefacts_in_section
      @artefacts ||= Artefact.any_in(:tag_ids => [@section.tag_id]).to_a
    end
end
