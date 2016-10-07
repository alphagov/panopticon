require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "rails/test_unit/railtie"
require "sass"
require "sprockets/railtie"
require 'kaminari' # has to be loaded before the models, otherwise the methods aren't added
require "govuk_content_models"
require "gds_api/publishing_api"
require "gds_api/rummager"
require "gds_api/publishing_api_v2"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Panopticon
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.prefix = '/assets'

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Disable Rack::Cache.
    config.action_dispatch.rack_cache = nil

    def publishing_api
      @publishing_api ||= GdsApi::PublishingApi.new(
        Plek.current.find('publishing-api'),
        bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
      )
    end

    def publishing_api_v2
      @publishing_api_v2 ||= GdsApi::PublishingApiV2.new(
        Plek.current.find('publishing-api'),
        bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
      )
    end

    def rummager
      @rummager ||= GdsApi::Rummager.new(Plek.current.find('rummager'))
    end
  end
end
