class RemoveUnusedChildBrowseTags < Mongoid::Migration

  TAG_IDS = %w(
    childcare-parenting/time-off-new-child
    childcare-parenting/child-into-care
  )

  def self.up
    TAG_IDS.each { |tag_id|
    tag = Tag.where(tag_id: tag_id).first
     if tag
        tag.destroy
        puts "Tag with id #{tag_id} destroyed"
     end
    }
  end

  def self.down
    # Nothing to do here
  end
end
