namespace :migrate do
  desc "Change the parent id for a given tag"
  task :change_tag_parent, [:tag_id, :new_parent] => :environment do |t, args|
    # justice/court-claims-debt-bankruptcy
    puts args.inspect
    tag = Tag.where(tag_id: "#{args[:tag_id]}").first
    if tag.nil?
      raise "Wa? No frakkin' tag with tag_id #{args[:tag_id]}"
    end
    parent = Tag.where(tag_id: "#{args[:new_parent]}").first
    if parent.nil?
      raise "Wa? No frakkin' parent with that tag_id #{args[:new_parent]}"
    end
    old_tag_id = tag.tag_id
    tag.tag_id = "#{parent.tag_id}/#{tag.tag_id.split("/")[1]}"
    tag.parent_id = parent.tag_id
    tag.save!
    new_tag_id = tag.tag_id

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
