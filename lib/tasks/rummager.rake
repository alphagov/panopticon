namespace :rummager do

  desc "Reindex (with an amend) live artefacts in rummager"
  task :reindex_live_artefacts => :environment do
    artefact_scope = Artefact.where(:state => 'live', :owning_app.ne => 'whitehall')
    total = artefact_scope.count
    puts "Re-indexing (amending) live artefacts"
    artefact_scope.each_with_index do |artefact, i|
      i += 1 # Humans prefer 1-indexed counters
      begin
        RummageableArtefact.new(artefact).submit
      rescue RestClient::ResourceNotFound => e
        puts "artefact #{artefact.slug} not in search index, so can't amend.  skipping."
      rescue
        puts "error registering #{artefact.slug}"
        raise
      end
      puts "done #{i}/#{total}" if i % 100 == 0
    end
  end
end
