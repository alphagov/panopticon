# Load the rails application
require File.expand_path('../application', __FILE__)

use "Slimmer::App", :template_host => "#{File.dirname(__FILE__)}/../public/templates"

# Initialize the rails application
Panopticon::Application.initialize!
