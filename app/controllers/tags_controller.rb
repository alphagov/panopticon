class TagsController < ApplicationController

  TAG_TYPES = ['section', 'specialist_sector']

  def index
    @tags = Tag.where(:tag_type.in => TAG_TYPES)
  end

  def new
    @tag = Tag.new
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

end
