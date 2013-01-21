require_relative 'test_helper'
require 'capybara/rails'

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    DatabaseCleaner.clean
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.use_default_driver
  end

  def create_test_user
    FactoryGirl.create(:user)
  end
end

