class MoreUpdatesToSomeVisaAndImmigrationSubsections < Mongoid::Migration

  def self.up
    self.renamed_sections.each do |old_slug, new_slug|
      current_tag_id = "#{self.parent_id}/#{old_slug}"
      new_tag_id = "#{self.parent_id}/#{new_slug}"

      self.reslug_section_tag(current_tag_id, new_tag_id)
    end
  end

  def self.down
    self.renamed_sections.each do |old_slug, new_slug|
      current_tag_id = "#{self.parent_id}/#{new_slug}"
      new_tag_id = "#{self.parent_id}/#{old_slug}"

      self.reslug_section_tag(current_tag_id, new_tag_id)
    end
  end

  private
  def self.parent_id
    "visas-immigration"
  end

  def self.renamed_sections
    [
      ["study-visas", "student-visas"],
      ["short-stay-visas", "tourist-short-stay-visas"],
      ["long-stay-visas", "family-visas"],
    ]
  end

  def self.reslug_section_tag(current_tag_id, new_tag_id)
    section = Tag.where(tag_id: current_tag_id, tag_type: 'section').first
    if section.present?
      section.update_attributes!(tag_id: new_tag_id)
      puts "Renamed #{current_tag_id} -> #{new_tag_id}"

      tagged_artefacts = Artefact.where(:tag_ids => current_tag_id)
      tagged_artefacts.each do |artefact|
        artefact.section_ids = (artefact.section_ids - [current_tag_id] + [new_tag_id])

        if artefact.save
          puts "\t -> Updated tags for #{artefact.slug}"
        else
          puts "\t -> Could not update tags for #{artefact.slug}"
        end
      end
    else
      puts "Skipping rename: couldn't find #{current_tag_id}"
    end
  end
end
