class UpdateSomeVisasAndImmigrationSubsections < Mongoid::Migration
  def self.up

    self.renamed_sections.each do |old_slug, new_slug|
      old_tag_id = "#{self.parent_id}/#{old_slug}"
      new_tag_id = "#{self.parent_id}/#{new_slug}"

      section = Tag.where(tag_id: old_tag_id, tag_type: 'section').first
      if section.present?
        section.update_attributes!(tag_id: new_tag_id)
        puts "Renamed #{old_tag_id} -> #{new_tag_id}"

        tagged_artefacts = Artefact.where(:tag_ids => old_tag_id)
        tagged_artefacts.each do |artefact|
          artefact.section_ids = (artefact.section_ids - [old_tag_id] + [new_tag_id])
          artefact.save!

          if artefact.save
            puts "\t -> Updated tags for #{artefact.slug}"
          else
            puts "\t -> Could not update tags for #{artefact.slug}"
          end
        end
      else
        puts "Skipping rename: couldn't find #{old_tag_id}"
      end
    end
  end

  def self.down

    self.renamed_sections.each do |old_slug, new_slug|
      old_tag_id = "#{self.parent_id}/#{old_slug}"
      new_tag_id = "#{self.parent_id}/#{new_slug}"

      section = Tag.where(tag_id: new_tag_id, tag_type: 'section').first
      if section.present?
        section.update_attributes!(tag_id: old_tag_id)
        puts "Reverted #{new_tag_id} -> #{old_tag_id}"

        tagged_artefacts = Artefact.where(:tag_ids => new_tag_id)
        tagged_artefacts.each do |artefact|
          artefact.section_ids = (artefact.section_ids - [new_tag_id] + [old_tag_id])
          if artefact.save
            puts "\t -> Updated tags for #{artefact.slug}"
          else
            puts "\t -> Could not update tags for #{artefact.slug}"
          end
        end
      else
        puts "Skipping revert: couldn't find #{new_tag_id}"
      end
    end
  end

  private
  def self.parent_id
    "visas-immigration"
  end

  def self.renamed_sections
    [
      ["after-youve-applied", "manage-your-application"],
      ["long-visit-visas", "long-stay-visas"],
      ["settling-in-the-uk", "settle-in-the-uk"],
      ["short-visit-visas", "short-stay-visas"],
      ["sponsoring-workers-students", "sponsor-workers-students"],
    ]
  end
end
