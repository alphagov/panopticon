class TagsController < ApplicationController

  TAG_TYPES = ['section', 'specialist_sector']

  before_filter :find_tag, only: [:edit, :update]

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

end
