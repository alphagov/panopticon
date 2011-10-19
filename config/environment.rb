# Load the rails application
require File.expand_path('../application', __FILE__)

config.middleware.insert 0, "Slimmer::App", :template_host => "#{config.root}/public/templates"

# Initialize the rails application
Panopticon::Application.initialize!
