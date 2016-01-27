require 'artefact_slug_migrator'

namespace :artefact_slug_migrator do
  desc "Migrate the artefact slugs specified in data/slugs_to_migrate.json"
  task run: :environment do
    ArtefactSlugMigrator.new.run
  end
end
