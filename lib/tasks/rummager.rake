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

  desc "Reindex specialist sectors"
  task :specialist_sector_reindex => :environment do
    sector_tags = Tag.where(tag_type: 'specialist_sector')
    puts "Re-indexing all #{sector_tags.count} specialist sectors"

    indexed = 0
    deleted = 0

    sector_tags.each do |sector_tag|
      if sector_tag.draft?
	puts "Skipping draft sector: #{sector_tag.tag_id}"
	next
      end
      artefact = Artefact.where(kind: 'specialist_sector', slug: sector_tag.tag_id).first

      rummageable_artefact = RummageableArtefact.new(artefact)
      if rummageable_artefact.should_be_indexed?
        rummageable_artefact.submit
        puts "Sent #{sector_tag.tag_id} for indexing"
	indexed += 1
      elsif artefact.archived?
        rummageable_artefact.delete
        puts "Sent delete request for #{sector_tag.tag_id}"
	deleted += 1
      end
    end

    puts "Indexed #{indexed} and deleted #{deleted} specialist sectors"
  end
end
