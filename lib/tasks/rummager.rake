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

  desc "Index live artefacts not present in rummager"
  task :index_and_reindex => :environment do
    artefact_scope = Artefact.where(:state => 'live', :owning_app.ne => 'whitehall')
    total = artefact_scope.count
    puts "Re-indexing (amending) live artefacts"
    artefact_scope.each_with_index do |artefact, i|
      i += 1 # Humans prefer 1-indexed counters
      begin
        artefact = RummageableArtefact.new(artefact).submit
      rescue RestClient::ResourceNotFound => e
        if artefact.kind == 'campaign'
          logger.info "Posting document to Rummager: #{artefact_link}"
          SearchIndex.instance.add(artefact.artefact_hash)
        else
          puts "artefact #{artefact.slug} not in search index, so can't amend.  skipping."
        end
      rescue
        puts "error registering #{artefact.slug}"
        raise
      end
      puts "done #{i}/#{total}" if i % 100 == 0
    end
  end
end
