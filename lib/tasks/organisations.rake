require 'organisation_importer'

namespace :organisations do
  # This task is run at 3AM every day with cron.
  # See https://github.gds/gds/alphagov-deployment/blob/master/panopticon/to_upload/config/production/schedule.rb
  desc "Import organisations from the Organisations API."
  task :import => :environment do
    OrganisationImporter.new.run
  end
end
