class RemoveRpaSpecialistSectors < Mongoid::Migration
  TAG_TYPE = "specialist_sector"

  def self.up
    tags_to_remove.each do |tag_id, _, _|
      tag = Tag.by_tag_id(tag_id, TAG_TYPE)

      if tag.present?
        if tag.destroy
          puts "Deleted specialist sector: #{tag_id}"
        else
          puts "Could not delete specialist sector: #{tag_id}"
        end
      else
        puts "Could not find specialist sector: #{tag_id}"
      end
    end
  end

  def self.down
    tags_to_remove.each do |tag_id, title, parent_id|
      tag = Tag.by_tag_id(tag_id, TAG_TYPE)

      if tag.present?
        puts "Specialist sector #{tag_id} already exists"
      else
        Tag.create!(tag_id: tag_id, title: title, parent_id: parent_id, tag_type: TAG_TYPE)
        puts "Created specialist sector: #{title} (#{tag_id})"
      end
    end
  end

private
  def self.tags_to_remove
    [
      ["working-sea/fishing", "Fishing", "working-sea"],
      ["producing-distributing-food/inspections", "Inspections", "producing-distributing-food"],
      ["keeping-farmed-animals/inspections", "Inspections", "keeping-farmed-animals"],
    ]
  end
end
