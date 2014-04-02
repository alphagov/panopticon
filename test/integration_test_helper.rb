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

  def login_as(user)
    GDS::SSO.test_user = user
  end

  def login_as_user_with_permission(permission)
    user = create(:user, permissions: ['signin', permission])
    login_as(user)
  end
end
