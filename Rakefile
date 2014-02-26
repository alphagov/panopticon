#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'dotenv'
Dotenv.load
ENV["COVERAGE"] = "true"
ENV["GOVUK_APP_DOMAIN"] = ENV.fetch("GOVUK_APP_DOMAIN", "dev.gov.uk")
ENV["GOVUK_WEBSITE_ROOT"] = ENV.fetch("GOVUK_WEBSITE_ROOT", "http://www.#{ENV["GOVUK_APP_DOMAIN"]}")
require File.expand_path('../config/application', __FILE__)

Panopticon::Application.load_tasks

task :default => [:test]