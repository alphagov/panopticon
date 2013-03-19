#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

ENV["COVERAGE"] = "true"
ENV["GOVUK_WEBSITE_ROOT"] = ENV.fetch("GOVUK_WEBSITE_ROOT", "http://www.dev.gov.uk")
require File.expand_path('../config/application', __FILE__)

Panopticon::Application.load_tasks

task :default => [:test, :check_for_bad_time_handling]