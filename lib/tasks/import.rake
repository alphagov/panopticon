require 'importers/mainstream_organisation_tag_importer'

namespace :import do

  desc "Import organisation tags for mainstream content from the Need API"
  task :mainstream_organisation_tags => :environment do
    Importers::MainstreamOrganisationTagImporter.new(
      Panopticon.need_api
    ).run
  end

end
