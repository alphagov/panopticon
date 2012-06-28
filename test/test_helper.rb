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
require 'mocha'
require 'govuk_content_models/test_helpers/factories'
FakeWeb.allow_net_connect = false

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

  def login_as_stub_user
    temp_user = FactoryGirl.create(:user, :name => 'Stub User')
    request.env['warden'] = stub(:authenticate! => true, :authenticated? => true, :user => temp_user)
  end

  alias_method :refute, :assert_false
end
