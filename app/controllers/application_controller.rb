class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :authenticate_user!
  before_filter :require_signin_permission!

  rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found

  def record_not_found
    render text: "404 Not Found", status: 404
  end
#  protect_from_forgery
end
