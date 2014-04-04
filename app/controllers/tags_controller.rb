class TagsController < ApplicationController

  TAG_TYPES = ['section', 'specialist_sector']

  before_filter :require_tags_permission
  before_filter :find_tag, only: [:edit, :update]
  helper_method :artefacts_in_section

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
    if tag_can_have_curated_list?(@tag) && params[:curated_list]
      update_curated_list
    end

    valid_tag_params = params[:tag].except(:parent_id, :tag_id)

    if @tag.update_attributes(valid_tag_params)
      flash[:notice] = "Tag has been updated"
      redirect_to tags_path
    else
      render action: :edit
    end
  end

  private
  def require_tags_permission
    authorise_user!("manage_tags")
  end

  def find_tag
    @tag = Tag.find(params[:id])

    find_or_initialize_curated_list if tag_can_have_curated_list?(@tag)
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

  # TODO: Improve curated list implementation. This was copied en-masse from the
  # existing 'browse sections' UI. We might be able to add a Mongoid has_one
  # relation between a tag and a curated list, and then use nested attributes so
  # that the code here becomes a lot cleaner
  def find_or_initialize_curated_list
    tag_id_as_curated_list_slug = @tag.tag_id.gsub(%r{/}, "-")
    existing_list = CuratedList.where(slug: tag_id_as_curated_list_slug).first

    if existing_list.present?
      @curated_list = existing_list
    else
      @curated_list = CuratedList.new(slug: tag_id_as_curated_list_slug, sections: [@tag.tag_id])
    end
  end

  def update_curated_list
    clean_artefact_ids = params[:curated_list][:artefact_ids].reject(&:blank?)
    @curated_list.update_attributes(artefact_ids: clean_artefact_ids)
  end

  def artefacts_in_section
    @artefacts ||= Artefact.any_in(:tag_ids => [@tag.tag_id]).not_archived.to_a
  end

  def tag_can_have_curated_list?(tag)
    tag.tag_type == 'section' && tag.has_parent?
  end
end
