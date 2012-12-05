#!/bin/bash -x
govuk_setenv panopticon env RAILS_ENV=test bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
govuk_setenv panopticon env RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load
govuk_setenv panopticon env RAILS_ENV=test bundle exec rake
