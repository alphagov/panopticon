class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :authenticate_user!
  before_filter :require_signin_permission!

#  protect_from_forgery
end
