source 'https://rubygems.org'

gem 'plek', '~> 1.8'

gem 'nested_form', '0.3.2'

gem 'ansi'
gem 'gelf'

gem 'airbrake', '3.1.15'
gem 'statsd-ruby', '~> 1.3.0'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '25.1.0'
end

gem 'govuk_message_queue_consumer', '~> 3.0.1'

gem 'rails', '4.2.5.2'
gem 'unicorn', '4.3.1'

gem 'rummageable', '1.0.1'

gem 'mongoid_rails_migrations', '1.0.0'
gem 'kaminari', '0.14.1'
gem 'bootstrap-kaminari-views', '0.0.3'
gem 'logstasher', '0.4.8'

if ENV['CONTENT_MODELS_DEV']
  gem 'govuk_content_models', path: '../govuk_content_models'
else
  gem 'govuk_content_models', '35.0.0'
end

gem 'rake', '10.5.0'
gem 'therubyracer', '0.12.0'
gem 'sass-rails', '5.0.4'
gem 'uglifier', '>= 2.7.2'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', path: '../gds-sso'
else
  gem 'gds-sso', '~> 11.2.1'
end

gem 'govuk_admin_template', '3.0.0'
gem 'formtastic', '2.3.0.rc4'
gem 'formtastic-bootstrap', '3.0.0'
gem 'jquery-ui-rails', '5.0.0'
gem 'chosen-rails', '1.4.2'
gem 'select2-rails', '3.5.9.1'
gem 'responders', '~> 2.0'

gem 'whenever', '0.9.2', require: false


group :development do
  gem 'quiet_assets'
end

group :test do
  gem 'simplecov', '~> 0.6.4'
  gem 'simplecov-rcov'
  gem 'ci_reporter_minitest', '1.0.0'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'shoulda', '~> 3.5.0'
  gem 'factory_girl', '3.3.0'
  gem 'factory_girl_rails'
  gem 'capybara', '~> 2.1.0'
  gem 'capybara-mechanize', '~> 1.1.0'
  gem 'mechanize', '~> 2.7.2'
  gem 'launchy'
  gem 'mocha', '1.1.0', :require => false
  gem 'webmock', require: false
  gem 'poltergeist', '~> 1.6.0'
  gem 'pry', '~> 0.10.3'
  gem 'pry-byebug'
end

group :import do
  gem 'nokogiri', '>= 1.6.7.2'
end
