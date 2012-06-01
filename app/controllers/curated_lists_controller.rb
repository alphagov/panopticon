class CuratedListsController < ApplicationController
  respond_to :json

  def index
    curated_lists = {}
    CuratedList.all.map do |curated_list|
      curated_lists[curated_list.slug] = curated_list.artefacts.map(&:slug)
    end
    respond_with(curated_lists)
  end
end
