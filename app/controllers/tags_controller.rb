class TagsController < ApplicationController
  respond_to :json

  def index
    @tags = TagRepository.load_all
    # TODO: links: [next_page, prev_page]
    respond_with(:status => 'ok', :total => @tags.count, :from => 0, :to => @tags.count - 1,
                 :pagesize => @tags.count, :results => @tags)
  end

  def show
    @tag = TagRepository.load(params[:id])
    if not @tag
      head :not_found and return
    end
    respond_with(:status=>'ok', :tag => @tag)
  end

end