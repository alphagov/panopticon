class ApplicationController < ActionController::Base
  include SlimmerTemplate
  slimmer_template :admin
  protect_from_forgery
end
