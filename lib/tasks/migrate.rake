namespace :migrate do
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
