class DeleteAbroadTag < Mongoid::Migration
  def self.up
    Tag.any_in(tag_id: ["abroad", "abroad/living-abroad", "abroad/travel-abroad"]).delete
  end

  def self.down
  end
end
