if ENV["COVERAGE"]
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

require 'database_cleaner'

ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/setup'
require 'webmock/minitest'
# this is to allow Poltergeist JS tests to talk to the local server
WebMock.disable_net_connect!(:allow_localhost => true)
require 'govuk_content_models/test_helpers/factories'

DatabaseCleaner.strategy = :truncation
# initial clean
DatabaseCleaner.clean

class ActiveSupport::TestCase
  include Rack::Test::Methods

  def clean_db
    DatabaseCleaner.clean
  end
  set_callback :teardown, :before, :clean_db

  def app
    Panopticon::Application
  end

  def stub_user
    @stub_user ||= FactoryGirl.create(:odi_user, :name => 'Stub User')
  end

  def login_as_stub_user
    login_as stub_user
  end

  def login_as(user)
    request.env['warden'] = stub(
      :authenticate! => true,
      :authenticated? => true,
      :user => user
    )
  end

  def create_test_user
    FactoryGirl.create(:odi_user)
  end
end

SEARCH_ROOT = "http://search.#{ENV['GOVUK_APP_DOMAIN']}"
