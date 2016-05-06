class TagsController < ApplicationController

  TAG_TYPES = ['section', 'specialist_sector']

  wrap_parameters :tag
  before_filter :require_tags_permission
  before_filter :find_tag, only: [:publish, :destroy]

  rescue_from Tag::TagNotFound, with: :record_not_found

  def create
    @tag = Tag.new(tag_parameters)

    if @tag.parent_id.present? && request.format.html?
      @tag.tag_id = "#{@tag.parent_id}/#{@tag.tag_id}"
    end

    if @tag.save
      resp = @tag.as_json
      render json: resp, status: :created
    else
      render json: { errors: @tag.errors }, status: :unprocessable_entity
    end
  end

  def update
    find_or_build_tag

    if @tag.new_record?
      valid_tag_params = tag_parameters
      success_status = :created
    else

      if disallowed_update_params.any?
        render status: :unprocessable_entity,
               json: { errors: disallowed_update_params_errors }
        return
      end

      valid_tag_params = tag_parameters.except(*disallowed_update_param_keys)
      success_status = :ok
    end

    if @tag.update_attributes(valid_tag_params)
      head success_status
    else
      render json: { errors: @tag.errors }, status: :unprocessable_entity
    end
  end

  def publish
    @tag.publish! if @tag.draft?
    head :ok
  end

  def destroy
    if Artefact.with_tags([@tag.tag_id]).any?
      render json: { error: 'Tag has documents tagged to it' }, status: 409
    else
      @tag.destroy
      head :ok
    end
  end

private
  def require_tags_permission
    authorise_user!("manage_tags")
  end

  def tag_parameters
    params[:tag].permit(:tag_id, :tag_type, :title, :parent_id, :description)
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

  def find_or_build_tag
    find_tag
  rescue Tag::TagNotFound
    @tag = Tag.new
  end
end
