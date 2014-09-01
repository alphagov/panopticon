namespace :rummager do
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
