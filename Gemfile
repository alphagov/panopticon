source 'http://rubygems.org'

group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

gem 'plek', '~> 0'
gem 'formtastic', '2.0.0.rc5'
gem 'stomp'
gem 'pethau'
gem 'marples', '~> 1.0'
gem 'daemonette', :git => 'git@github.com:alphagov/daemonette.git'
gem 'whenever'             
gem 'ansi'

gem 'exception_notification'

gem 'gds-api-adapters', '~> 0.0.15'
gem 'aws-ses', :require => 'aws/ses'

gem 'rails', '~> 3.1.1'

gem 'mysql2'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', :path => '../gds-sso'
else
  gem 'warden', '1.0.6'
  gem 'gds-sso', :git => 'git@github.com:alphagov/gds-sso.git'
end

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '~> 1.1'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'sqlite3-ruby', :require => false
  gem 'simplecov', '0.4.2'
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
  gem 'fakeweb'
end

group :import do
  gem 'nokogiri'
end
