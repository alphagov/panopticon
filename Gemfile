source 'http://rubygems.org'

group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

gem 'plek', '0.1.0'
gem 'formtastic', '2.0.0.rc5'

gem 'rails', '~> 3.1.1'

gem 'mysql2'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', :git => 'git@github.com:alphagov/slimmer.git'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'sqlite3-ruby', :require => false
  gem 'simplecov', '0.4.2'
  gem 'simplecov-rcov'
  gem 'ci_reporter'
  gem 'test-unit'
end

group :import do
  gem 'nokogiri'
end
