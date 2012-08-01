namespace :migrate do
  desc "Populate tag objects with parent ids"
  task :populate_tag_parent_ids => :environment do
    Tag.all.each do |tag|
      bits = tag.tag_id.split("/")
      if bits.size() > 1
        parent = Tag.where(tag_id: bits[0]).first
        if not parent.nil?
          tag.parent_id = parent.tag_id
          tag.save
        end
      end
    end
  end
end