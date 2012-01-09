class ApplicationController < ActionController::Base
  include Slimmer::Template
  include GDS::SSO::ControllerMethods
  slimmer_template :admin

  before_filter :authenticate_user!
  
#  protect_from_forgery
end
