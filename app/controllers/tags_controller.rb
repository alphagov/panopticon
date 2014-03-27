class TagsController < ApplicationController

  TAG_TYPES = ['section', 'specialist_sector']

  before_filter :find_tag, only: [:edit, :update]

  def index
    @parents = tags_grouped_by_parents
  end

  def new
    @tag = Tag.new

    if params[:type].present?
      @tag.tag_type = params[:type]

      if params[:parent_id].present?
        @tag.parent_id = params[:parent_id]
        @tag.tag_id = "#{params[:parent_id]}/"
      end
    end
  end

  def create
    @tag = Tag.new(params[:tag])

    if @tag.save
      flash[:notice] = "Tag has been created"
      redirect_to tags_path
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @tag.update_attributes(params[:tag])
      flash[:notice] = "Tag has been updated"
      redirect_to tags_path
    else
      render action: :edit
    end
  end

  private
  def find_tag
    @tag = Tag.find(params[:id])
  end

  def tags_grouped_by_parents
    tags_in_groups = Tag.where(:tag_type.in => TAG_TYPES).order_by([:title, :asc]).group_by(&:parent_id).to_a

    # if there are no tags returned, we shouldn't continue
    return [] unless tags_in_groups.any?

    # find the group for the 'nil' parent_id, as this contains all the root tags.
    # discard the first value in the array, as we only want the array of tags.
    _, root_tags = tags_in_groups.find {|parent_id,_| parent_id == nil }

    # iterate over the root tags, finding the children of each root tag as we go.
    # we then build a similar group array structure, where the parent tag is the
    # first item and the children (if any) are the last item.
    root_tags.map {|tag|
      _, children = tags_in_groups.find {|parent_id, _| parent_id == tag.tag_id }

      [
        tag,
        children || []
      ]
    }
  end

end
