namespace :migrate do
  task :swap_old_tag_uniqueness_index do
    Tag.collection.drop_index('tag_id_1') # this is the generated name for the unique index of tags by tag_id
    Tag.collection.create_index([ [:tag_id, Mongo::ASCENDING], [:tag_type, Mongo::ASCENDING] ], unique: true)
  end

  desc "Sets the businesslink legacy source on all business proposition content"
  task :set_businesslink_tag_on_buisiness_artefacts => :environment do
    Artefact.observers.disable :update_search_observer, :update_router_observer do
      Artefact.where(:business_proposition => true).each do |artefact|
        unless artefact.legacy_source_ids.include?('businesslink')
          artefact.legacy_source_ids += %w(businesslink)
          artefact.save!
        end
      end
    end
  end
end
