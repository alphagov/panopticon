require_relative 'test_helper'
require 'capybara/rails'
require 'webmock'

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include WebMock::API

  setup do
    DatabaseCleaner.clean
  end

  teardown do
    DatabaseCleaner.clean
    WebMock.reset!  # Not entirely sure whether this happens anyway
    Capybara.use_default_driver
  end

  def create_test_user
    FactoryGirl.create(:user)
  end
end
