source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'gds-warmup-controller', '0.1.0'

gem 'plek', '~> 0.3.0'
gem 'formtastic', git: 'https://github.com/justinfrench/formtastic.git', branch: '2.1-stable'
gem 'formtastic-bootstrap', git: 'https://github.com/cgunther/formtastic-bootstrap.git', branch: 'bootstrap-2'
gem 'stomp'
gem 'whenever'
gem 'ansi'
gem 'gelf'
gem 'null_logger'

gem 'exception_notification'

gem 'gds-api-adapters'
gem 'router-client', "3.1.0"

gem 'aws-ses', require: 'aws/ses'

gem 'rails', '3.2.7'
gem 'unicorn', '4.3.1'

gem 'colorize', '~> 0.5.8'
gem 'rummageable', "~> 0.3.0"

gem "mongoid", "~> 2.4.2"
gem "mongo", "1.6.2"
gem "bson_ext", "1.6.2"
gem "bson", "1.6.2"
gem 'lograge'

if ENV['CONTENT_MODELS_DEV']
  gem "govuk_content_models", path: '../govuk_content_models'
else
  gem "govuk_content_models", "1.7.1"
end

if ENV['BUNDLE_DEV']
  gem 'gds-sso', path: '../gds-sso'
else
  gem 'gds-sso', '~> 1.2.0'
end

group :assets do
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end

group :test do
  # Pretty printed test output
  gem 'turn', require: false
  gem 'sqlite3-ruby', require: false
  gem 'simplecov', '~> 0.6.4'
  gem 'simplecov-rcov'
  gem 'ci_reporter'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'minitest'
  gem "shoulda", "~> 2.11.3"
  gem 'factory_girl', "3.3.0"
  gem 'factory_girl_rails'
  gem 'capybara-mechanize', '~> 0.3.0.rc3'
  gem 'launchy'
  gem 'mocha'
  gem 'webmock', require: false
end

group :import do
  gem 'nokogiri'
end
