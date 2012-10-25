class TagsController < ApplicationController
  respond_to :html

  def index
    redirect_to categories_path
  end

  def edit
    @tag = TagRepository.load(params[:id])
    respond_with @tag
  end

  def update
    # Semantic form uses, by default, the to_param method on the model, _id
    # our tag models are somewhat non conventional and ideally we'd need it to
    # use tag_id, rather than _id
    # This is a work around, let semantic form send us the _id and find it ourselves.
    # TODO: modify the to_param within govuk_content_models
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = "Successfully updated"
      redirect_to edit_tag_path(CGI.escape(@tag.tag_id))
    else
      respond_with @tag
    end
  end

  def categories
    @tags = TagRepository.load_all({:tag_type => 'section'}).order_by([:tag_id, :asc])
    respond_with @tags
  end
end
