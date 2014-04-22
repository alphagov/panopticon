#!/bin/bash -x

set -e

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:drop db:create db:schema:load
bundle exec rake
