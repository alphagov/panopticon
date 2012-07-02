require 'capybara/mechanize'
Capybara.default_driver = :mechanize

World(Rack::Test::Methods)