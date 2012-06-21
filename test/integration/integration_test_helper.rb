require_relative '../test_helper'
require 'capybara/rails'
require 'capybara/mechanize'
require 'webmock'

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include WebMock

  def setup
    DatabaseCleaner.clean

    WebMock.allow_net_connect!
    stub_request(:get, /assets\.test\.gov\.uk/).to_return(status: 404)
  end

  def teardown
    DatabaseCleaner.clean
    WebMock.reset!  # Not entirely sure whether this happens anyway
  end

end

Capybara.app = Rack::Builder.new do
  map "/" do
    run Capybara.app
  end
end

Capybara.default_driver = :mechanize