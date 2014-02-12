class RenameIndustrySectorTagTypeToSpecialistSector < Mongoid::Migration
  def self.up
    Tag.where(tag_type: "industry_sector").update_all(tag_type: "specialist_sector")
  end

  def self.down
    Tag.where(tag_type: "specialist_sector").update_all(tag_type: "industry_sector")
  end
end
