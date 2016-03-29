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
require 'gds_api/test_helpers/publishing_api'

require 'minitest/reporters'
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new(color: true),
)

DatabaseCleaner.strategy = :truncation
# initial clean
DatabaseCleaner.clean

class ActiveSupport::TestCase
  include Rack::Test::Methods
  include FactoryGirl::Syntax::Methods
  include GdsApi::TestHelpers::PublishingApi

  def clean_db
    DatabaseCleaner.clean
  end
  set_callback :teardown, :before, :clean_db

  set_callback :setup, :before, :stub_default_publishing_api_path_reservation

  def app
    Panopticon::Application
  end

  def stub_user
    @stub_user ||= FactoryGirl.create(:user, :name => 'Stub User')
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
    FactoryGirl.create(:user)
  end

  def stub_all_router_api_requests
    WebMock.stub_request(:any, %r{\A#{Plek.current.find('router-api')}/}).to_return(:status => 200)
  end

  def stub_all_rummager_requests
    WebMock.stub_request(:any, %r{\A#{SearchIndex.rummager_host}})
  end

  def stub_artefact_callbacks
    Artefact.any_instance.stubs(:update_router)
    Artefact.any_instance.stubs(:update_search)
    Artefact.any_instance.stubs(:remove_related_artefacts)
  end

  def unstub_artefact_callbacks
    Artefact.any_instance.unstub(:update_router)
    Artefact.any_instance.unstub(:update_search)
    Artefact.any_instance.unstub(:remove_related_artefacts)
  end

  def without_artefact_callbacks
    stub_artefact_callbacks
    yield
    unstub_artefact_callbacks
  end
end
