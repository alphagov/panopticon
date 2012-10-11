# This is a one time run script to change the slugs of two categories
# and update all artefacts that have been tagged with those sections
# TODO: Once this has been run, this script can be deleted

namespace :migrate do
  desc "Change slug for two categories"
  task :rename_two_category_slug => :environment do
    tag_mappings = [
      ["business/corporation-tax-capital-allowance", "business/business-tax"],
      ["driving/blue-badges-parking", "driving/blue-badge-parking"]
    ]
    tag_mappings.each do |old_tag_id, new_tag_id|
      t = Tag.where(tag_id: "#{old_tag_id}").first
      if t.nil?
        raise "Wa? No frakkin' tag with tag_id #{old_tag_id}"
      end
      t.tag_id = new_tag_id
      t.save!
      artefacts = Artefact.any_in(tag_ids: [old_tag_id])
      puts "#{artefacts.count} of artefacts tagged with #{old_tag_id}"
      artefacts.each do |a|
        puts "Artefact: #{a.slug} with tag_ids #{a.tag_ids}"
        index = a.tag_ids.index(old_tag_id)
        a.tag_ids[index] = new_tag_id
        a.save!
        puts "new tag_ids #{a.tag_ids}"
      end
    end
  end
end
