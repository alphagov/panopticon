class BrowseSectionsController < ApplicationController
  before_filter :require_permission

  def index
    @sections = Tag.where(tag_type: "section").order_by([:tag_id, :asc])
  end

  private
    def require_permission
      authorise_user!("Browse section admin")
    end
end
