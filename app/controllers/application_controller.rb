class ApplicationController < ActionController::Base
  include Slimmer::Template
  slimmer_template :admin
  protect_from_forgery
end
