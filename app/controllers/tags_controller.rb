class TagsController < ApplicationController

  TAG_TYPES = ['section', 'specialist_sector']

  before_filter :require_tags_permission
  before_filter :find_tag, only: [:edit, :update, :publish]

  rescue_from Tag::TagNotFound, with: :record_not_found

  def index
    @parents = tags_grouped_by_parents
  end

  def new
    @tag = Tag.new

    if params[:type].present?
      @tag.tag_type = params[:type]

      if params[:parent_id].present?
        @tag.parent_id = params[:parent_id]
      end
    end
  end

  def create
    @tag = form_object.new(tag_parameters)

    if @tag.parent_id.present? && request.format.html?
      @tag.tag_id = "#{@tag.parent_id}/#{@tag.tag_id}"
    end

    respond_to do |format|
      if @tag.save
        format.html {
          flash[:success] = "Tag has been created"
          redirect_to tags_path
        }
        format.json { render json: @tag, status: :created }
      else
        format.html { render action: :new }
        format.json {
          render json: { errors: @tag.errors }, status: :unprocessable_entity
        }
      end
    end
  end

  def edit
  end

  def update
    if disallowed_update_params.any?
      render status: :unprocessable_entity,
             json: { errors: disallowed_update_params_errors }
      return
    end

    valid_tag_params = tag_parameters.except(*disallowed_update_param_keys)

    respond_to do |format|
      if @tag.update_attributes(valid_tag_params)
        format.html {
          flash[:success] = "Tag has been updated"
          redirect_to tags_path
        }
        format.json { head :ok }
      else
        format.html { render action: :edit }
        format.json {
          render json: { errors: @tag.errors }, status: :unprocessable_entity
        }
      end
    end
  end

  def publish
    respond_to do |format|
      if @tag.draft?
        @tag.publish!

        format.html {
          flash[:success] = 'Tag has been published'
          redirect_to edit_tag_path(@tag)
        }
        format.json {
          head :ok
        }
      else
        format.html {
          flash[:error] = 'Tag is already live'
          redirect_to edit_tag_path(@tag)
        }
        format.json {
          render json: { error: 'Tag is already published' },
                 status: :unprocessable_entity
        }
      end

    end
  end

private
  def require_tags_permission
    authorise_user!("manage_tags")
  end

  def tag_parameters
    # Support tag parameters being provided at either the root or through the
    # 'tag' hash.
    #
    # Ideally this should be supported through Rails' wrap_parameters
    # functionality but it does not seem to work as per the documentation
    # in this circumstance (could be a Mongoid 2.x incompatibility).
    #
    params[:tag] ||
      params.slice(:tag_id, :tag_type, :title, :parent_id, :description)
  end

  def disallowed_update_param_keys
    [:tag_id, :parent_id, :tag_type]
  end

  def disallowed_update_params
    disallowed_update_param_keys.select {|key|
      tag_parameters.has_key?(key) && tag_parameters[key] != @tag.public_send(key)
    }
  end

  def disallowed_update_params_errors
    disallowed_update_params.inject({}) {|errors, (key,_)|
      errors.merge(key => ["can't be changed"])
    }
  end

  def find_tag
    @tag = Tag.find_by_param(params[:id])
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

  def form_object
    case tag_type
    when 'specialist_sector'
      SpecialistSectorTagForm
    else
      Tag
    end
  end

  def tag_type
    params[:tag] && params[:tag][:tag_type] || params[:type]
  end
end
