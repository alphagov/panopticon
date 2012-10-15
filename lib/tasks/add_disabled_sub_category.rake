# NOTE: This is to specifically create a disabilities sub category
# then tag all content with disabilities with this new sub category

namespace :migrate do
  desc "Create sub category and tag all content with disabilities tag_id with new sub cat"
  task :create_sub_category_and_tag => :environment do |t, args|
    tag = Tag.where(tag_id: "disabilities").first
    if tag.nil?
      raise "Wa? No frakkin' tag with tag_id #{args[:tag_id]}"
    end

    sub_cat = Tag.new({tag_id: "disabilities/disabled-people",
      parent_id: "disabilities", description: "Includes your rights, benefits and the Equality Act",
      tag_type: "section", title: "Disabled people"})
    sub_cat.save!
    puts "Created: #{sub_cat.inspect}"

    artefacts = Artefact.any_in(tag_ids: [tag.tag_id])
    artefacts.each do |a|
      a.tag_ids = a.tag_ids.append(sub_cat.tag_id)
      puts "Updating #{a.slug} with #{a.tag_ids}"
      a.save!
    end
  end
end
