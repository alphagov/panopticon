namespace :migrate do
  desc "Copy data from attr primary_section to taggable primary_section"
  task :move_primary_section_into_taggable => :environment do
    Artefact.observers.disable :update_search_observer, :update_router_observer do
      Artefact.all.each do |artefact|
        unless artefact.attributes['primary_section'].nil?
          puts "Updating #{artefact.slug} with #{artefact.attributes['primary_section']}"
          artefact.primary_section = artefact.attributes['primary_section']
          artefact.save!
        end
      end
    end
  end
end