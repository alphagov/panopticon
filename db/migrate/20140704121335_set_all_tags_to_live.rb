class SetAllTagsToLive < Mongoid::Migration
  def self.up
    Tag.update_all(state: 'live')
  end

  def self.down
    Tag.all.each {|tag|
      tag.unset(:state)
    }
  end
end
