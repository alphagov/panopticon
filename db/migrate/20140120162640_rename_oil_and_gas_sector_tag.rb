class RenameOilAndGasSectorTag < Mongoid::Migration
  def self.up
    tag = Tag.where(tag_id: "oil-and-gas/exploration-and-development", tag_type: "industry_sector").first

    tag.tag_id = "oil-and-gas/exploration-and-production"
    tag.title = "Exploration and production"

    tag.save!
  end

  def self.down
    tag = Tag.where(tag_id: "oil-and-gas/exploration-and-production", tag_type: "industry_sector").first

    tag.tag_id = "oil-and-gas/exploration-and-development"
    tag.title = "Exploration and development"

    tag.save!
  end
end
