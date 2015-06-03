class RenamePopulationScreeningTopicTags < Mongoid::Migration

  OLD_TAG_REGEX = /\Anhs-population-screening-programmes/

  def self.up
    Tag.where(:tag_type => "specialist_sector", :tag_id => OLD_TAG_REGEX).each do |tag|
      new_tag_id = tag.tag_id.sub(/\Anhs-/, '')
      puts "Updating tag slug #{tag.tag_id} -> #{new_tag_id}"
      tag.tag_id = new_tag_id
      tag.save!
    end

    puts "\nUpdating tagging on artefacts\n"
    Artefact.where(:tag_ids => OLD_TAG_REGEX).each do |artefact|
      existing_valid_sector_ids = artefact.specialist_sector_ids(true)
      # The above will only return sector_ids that relate to existing sectors,
      # so we have to find the old ones manually from the tag_ids
      sectors_to_update = artefact.tag_ids.select { |tag_id| tag_id =~ OLD_TAG_REGEX }

      new_sector_ids = existing_valid_sector_ids + sectors_to_update.map {|tag_id| tag_id.sub(/\Anhs-/, '') }
      puts "Updating topics for #{artefact.slug} (#{existing_valid_sector_ids + sectors_to_update} -> #{new_sector_ids})"
      artefact.specialist_sector_ids = new_sector_ids
      artefact.save!
    end
  end
end
