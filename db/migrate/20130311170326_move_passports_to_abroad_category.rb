class MovePassportsToAbroadCategory < Mongoid::Migration
  def self.up
    tag = Tag.where(tag_type: "section", tag_id: "citizenship/passports").first
    if tag
      tag.tag_id = "abroad/passports"
      tag.parent_id = "abroad"
      tag.save!
    end

    curated_list = CuratedList.any_in(tag_ids: ["citizenship/passports"]).first
    if curated_list
      curated_list.tag_ids = [tag_id_as_curated_list_slug("abroad/passports")]
      curated_list.save!
    end

    artefacts = Artefact.any_in(tag_ids: ["citizenship/passports"])
    artefacts.each do |artefact|
      artefact.section_ids = artefact.section_ids - ["citizenship/passports"]
      artefact.section_ids = artefact.section_ids + ["abroad/passports"]
      artefact.save!
    end
  end

  def self.tag_id_as_curated_list_slug(tag_id)
    tag_id.gsub(%r{/}, "-")
  end
end