# NOTE: this will only delete tags that have NO pieces of content associated with this tag
# AND NO CHILDREN TAGS ASSOCIATED

namespace :migrate do
  desc "Delete the given tag_id"
  task :delete_tag, [:tag_id] => :environment do |t, args|
    tag = Tag.where(tag_id: "#{args[:tag_id]}").first
    if tag.nil?
      raise "Wa? No frakkin' tag with tag_id #{args[:tag_id]}"
    end

    if tag.parent.nil?
      # we're a root section tag
      # make sure there are no children tags with us as a parent id
      children_tags = Tag.where(parent_id: tag.tag_id)
      if children_tags.count > 0
        tag_ids = children_tags.collect {|x| x.tag_id}
        raise "STOP! There are children tags #{tag_ids}"
      end
    end

    artefacts = Artefact.any_in(tag_ids: [tag.tag_id])
    if artefacts.count > 0
      raise "STOP! This has #{artefacts.count} artefacts associated with it"
    end

    tag.delete
    puts "Deleted #{tag.tag_id}"
  end
end
