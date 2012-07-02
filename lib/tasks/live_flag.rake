namespace :live_flag do
  task :populate => :environment do
    # Disable the search observer to avoid a mass update of Rummager
    Artefact.observers.disable :update_search_observer do
      Artefact.where(:owning_app.ne => "publisher").update(live: true)
      Artefact.where(owning_app: "publisher").each do |artefact|
        artefact.live = artefact.any_editions_published?
        artefact.save!
      end
    end
  end
end
