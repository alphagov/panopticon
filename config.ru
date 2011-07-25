app_path = File.dirname(__FILE__)
$:.unshift(app_path) unless $:.include?(app_path)
# require 'env'
require 'panopticon'

require "bundler"

Bundler.require(:default, ENV['RACK_ENV'])
run Sinatra::Application
