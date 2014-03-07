require 'organisation_importer'

namespace :organisations do
  desc "Import organisations from the Organisations API"
  task :import => :environment do
    OrganisationImporter.new.run
  end
end
