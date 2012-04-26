if ENV["COVERAGE"]
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

class ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Panopticon::Application
  end

  def login_as_stub_user
    temp_user = User.create!(:name => 'Stub User')
    request.env['warden'] = stub(:authenticate! => true, :authenticated? => true, :user => temp_user)
  end
end
