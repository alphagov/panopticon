require_relative 'test_helper'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  teardown do
    Capybara.use_default_driver
  end

  def put_json(path, attrs, headers = {})
    # Rack::Test put method calls to_json on whatever body you pass.
    # This is different to the post method.  Go figure.
    put path, attrs, {"Content-Type" => "application/json"}.merge(headers)
  end

  def stub_all_rummager_requests
    WebMock.stub_request(:any, %r{\A#{Rummageable.rummager_host}})
  end
end

