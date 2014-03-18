source 'https://rubygems.org'

gem 'plek', '1.7.0'

gem 'nested_form', '0.3.2'

gem 'ansi'
gem 'gelf'
gem 'null_logger'

gem 'airbrake', '3.1.15'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', "7.20.0"
end

gem 'aws-ses', require: 'aws/ses'

gem 'rails', '3.2.17'
gem 'unicorn', '4.3.1'

gem 'colorize', '~> 0.5.8'
gem 'rummageable', "~> 0.3.0"

gem "mongoid_rails_migrations", "1.0.0"
gem "kaminari", "0.14.1"
gem 'logstasher', '0.4.8'

# TODO: Investigate whether there is a requirement to pin these
# gems here, when they are dependencies of govuk_content_models
gem "mongoid", "~> 2.5"
gem "mongo", "1.7.1"
gem "bson_ext", "1.7.1"
gem "bson", "1.7.1"

if ENV['CONTENT_MODELS_DEV']
  gem "govuk_content_models", path: '../govuk_content_models'
else
  gem "govuk_content_models", "8.8.0"
end

if ENV['BUNDLE_DEV']
  gem 'gds-sso', path: '../gds-sso'
else
  gem 'gds-sso', '9.2.2'
end

gem 'formtastic', '2.2.1'
gem 'formtastic-bootstrap', '2.1.3'

gem 'bootstrap-sass', '2.3.2.2'

gem 'jquery-rails', '2.0.2'
gem 'jquery-ui-rails', '3.0.1'
gem 'chosen-rails', '1.0.2'

gem 'whenever', '0.9.2', require: false

group :assets do
  gem "therubyracer", "0.12.0"
  gem 'sass-rails', '3.2.6'
  gem 'uglifier'
end

group :development do
  gem 'quiet_assets'
end

group :test do
  # Pretty printed test output
  gem 'turn', require: false
  gem 'simplecov', '~> 0.6.4'
  gem 'simplecov-rcov'
  gem 'ci_reporter'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'minitest'
  gem "shoulda", "~> 2.11.3"
  gem 'factory_girl', "3.3.0"
  gem 'factory_girl_rails'
  gem 'capybara', '1.1.2'
  gem 'capybara-mechanize', '~> 0.3.0.rc3'
  gem 'launchy'
  gem 'mocha', '0.13.3', :require => false
  gem 'webmock', require: false
  gem 'poltergeist', '0.7.0'
end

group :import do
  gem 'nokogiri'
end
