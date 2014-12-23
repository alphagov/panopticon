require 'capybara/mechanize'
require 'capybara/poltergeist'
Capybara.default_driver = :mechanize
Capybara.javascript_driver = :poltergeist

World(Rack::Test::Methods)