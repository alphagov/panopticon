source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

gem 'gds-warmup-controller'

gem 'plek', '~> 0'
gem 'formtastic', git: 'git://github.com/justinfrench/formtastic.git', branch: '2.1-stable'
gem 'formtastic-bootstrap', git: 'git://github.com/cgunther/formtastic-bootstrap.git', branch: 'bootstrap-2'
gem 'stomp'
gem 'marples', '~> 1.0'
gem 'whenever'
gem 'ansi'
gem 'gelf'
gem 'null_logger'

gem 'exception_notification'

gem 'gds-api-adapters'
gem 'aws-ses', :require => 'aws/ses'

gem 'rails', '~> 3.1.1'

gem 'colorize', '~> 0.5.8'

gem "mongoid", "~> 2.4.2"
gem "mongo", "1.5.2"
gem "bson_ext", "1.5.2"
gem "bson", "1.5.2"

if ENV['CONTENT_MODELS_DEV']
  gem "govuk_content_models", :path => '../govuk_content_models'
else
  gem "govuk_content_models", "~> 0.1.00"
end

if ENV['BUNDLE_DEV']
  gem 'gds-sso', :path => '../gds-sso'
else
  gem 'gds-sso', '0.7.0'
end

group :assets do
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'sqlite3-ruby', :require => false
  gem 'simplecov', '~> 0.6.4'
  gem 'simplecov-rcov'
  gem 'ci_reporter'
  gem 'test-unit'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'minitest'
  gem "shoulda", "~> 2.11.3"
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'capybara-mechanize', '~> 0.3.0.rc3'
  gem 'launchy'
  gem 'fakeweb'
  gem 'mocha'
end

group :import do
  gem 'nokogiri'
end
