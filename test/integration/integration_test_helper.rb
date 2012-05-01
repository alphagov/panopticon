require_relative '../test_helper'
require 'capybara/rails'
require 'capybara/mechanize'
FakeWeb.allow_net_connect = true
FakeWeb.register_uri :get, /assets.test.gov.uk/, :status => [404, 'Not found']
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  def setup
    DatabaseCleaner.clean
  end

  def teardown
    DatabaseCleaner.clean
  end

end

Capybara.app = Rack::Builder.new do
  map "/" do
    run Capybara.app
  end
end

Capybara.default_driver = :mechanize