class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :authenticate_user!

#  protect_from_forgery
end
