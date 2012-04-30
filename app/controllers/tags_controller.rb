class TagsController < ApplicationController
  respond_to :json

  def index
    tags = TagRepository.load_all
    respond_with tags
  end

  def show
    tag = TagRepository.load(params[:id])
    if not tag
      head :not_found and return
    end
    respond_with tag
  end

end