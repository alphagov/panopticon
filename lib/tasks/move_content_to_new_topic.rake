desc "Move content from one topic to another"
task move_content_to_new_topic: :environment do
  source_topic_id = ENV.fetch('source')
  dest_topic_id = ENV.fetch('dest')

  source_topic = Tag.where(tag_id: source_topic_id, tag_type: "specialist_sector").first
  if source_topic.nil?
    puts "The source topic '#{source_topic_id}' could not be found"
    exit
  end

  dest_topic = Tag.where(tag_id: dest_topic_id, tag_type: "specialist_sector").first
  if dest_topic.nil?
    puts "The destination topic '#{dest_topic_id}' could not be found"
    exit
  end

  source_artefacts = Artefact.any_in(tag_ids: [source_topic_id])
  puts "Source tag #{source_topic_id} found with #{source_artefacts.count} artefacts"
  source_artefacts.each do |artefact|
    puts " - #{artefact.slug} #{artefact.name}"
  end

  dest_artefacts = Artefact.any_in(tag_ids: [dest_topic_id])
  puts "\nDestination tag #{dest_topic_id} found with #{dest_artefacts.count} artefacts"
  dest_artefacts.each do |artefact|
    puts " - #{artefact.slug} #{artefact.name}"
  end

  puts ""
  source_artefacts.each do |artefact|
    puts "Retagging #{artefact.slug}"
    new_topics = artefact.specialist_sectors.map { |topic|
      topic = dest_topic if topic == source_topic
      topic.tag_id
    }
    artefact.specialist_sectors = new_topics
    artefact.save!

    rummageable_artefact = RummageableArtefact.new(artefact)
    if rummageable_artefact.should_be_indexed?
      puts "Updating index #{rummageable_artefact}"
      rummageable_artefact.submit
    else
      puts "Artefact not indexed from panopticon"
    end
  end
end
