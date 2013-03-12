class AddAbroadBrowseCategory < Mongoid::Migration
  def self.up
    abroad_tag = Tag.create(
        tag_type: "section",
        title: "Passports, travel and living abroad",
        tag_id: "abroad",
        description: "Includes renewing passports and travel advice by country")

    Tag.create(
        tag_type: "section",
        title: "Living abroad",
        tag_id: "abroad/living-abroad",
        parent_id: abroad_tag.tag_id,
        description: "Includes tax, State Pension, benefits and UK government services abroad")

    Tag.create(
        tag_type: "section",
        title: "Travel abroad",
        tag_id: "abroad/travel-abroad",
        parent_id: abroad_tag.tag_id,
        description: "Includes the latest travel advice by country, finding a British embassy and getting help abroad")
  end

  def self.down
    Tag.any_in(tag_id: ["abroad", "abroad/living-abroad", "abroad/travel-abroad"]).delete
  end
end