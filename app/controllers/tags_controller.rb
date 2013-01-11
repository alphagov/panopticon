class TagsController < ApplicationController
  respond_to :json, :html

  def index
    if params[:type]
      @tags = Tag.where(tag_type: params[:type])
    else
      @tags = Tag.all
    end
    respond_with(status: 'ok', total: @tags.count, from: 0, to: @tags.count - 1,
      pagesize: @tags.count, results: @tags)
  end

  def show
    @tag = Tag.where(tag_id: params[:id]).first
    if @tag
      respond_with(status: 'ok', tag: @tag)
    else
      head :not_found
    end
  end

  def edit
    @tag = Tag.where(tag_id: params[:id]).first
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
    @tags = Tag.where(tag_type: 'section').order_by([:tag_id, :asc])
    respond_with @tags
  end
end
