class BrowseSectionsController < ApplicationController
  def index
    @sections = Tag.where(tag_type: "section").order_by([:tag_id, :asc])
  end
end
