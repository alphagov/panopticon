class ChangeVisasAndImmigrationSubsections < Mongoid::Migration
  def self.up

    # Create the new sections
    self.new_sections.each do |slug, title, description|
      child_tag_id = "#{self.parent_id}/#{slug}"
      unless Tag.where(tag_id: child_tag_id, tag_type: 'section').any?
        child = Tag.create!(tag_id: child_tag_id, tag_type: 'section', title: title, description: description, parent_id: self.parent_id)
        puts "Created #{child_tag_id}: #{child.title}"
      else
        puts "Skipping create: #{child_tag_id} as already exists"
      end
    end

    # Rename existing sections
    self.renamed_sections.each do |old_slug, new_slug, new_title|
      old_tag_id = "#{self.parent_id}/#{old_slug}"
      new_tag_id = "#{self.parent_id}/#{new_slug}"

      section = Tag.where(tag_id: old_tag_id, tag_type: 'section').first
      if section.present?
        section.update_attributes!(tag_id: new_tag_id, title: new_title)
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

    # Delete section
    deleted_tag_id = "#{self.parent_id}/joining-family-visas"
    tag_to_delete = Tag.where(tag_id: deleted_tag_id, tag_type: 'section').first

    if tag_to_delete.present?
      tag_to_delete.destroy
      puts "Deleted #{deleted_tag_id}"
    else
      puts "Skipping delete: couldn't find #{deleted_tag_id}"
    end
  end

  def self.down
    # Delete new sections
    new_section_ids = self.new_sections.map {|tag_id| "#{self.parent_id}/#{tag_id.first}"}
    deleted_count = Tag.where(:tag_id.in => new_section_ids).delete_all
    puts "Deleted #{deleted_count} new sections"

    # Revert renames of old tag ids (not changing the titles)
    self.renamed_sections.each do |old_slug, new_slug, new_title|
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

    # Re-create deleted tag
    Tag.create!(tag_id: "#{self.parent_id}/joining-family-visas", tag_type: 'section', title: "Joining family visas", parent_id: self.parent_id)
    puts "Re-created #{self.parent_id}/joining-family-visas"
  end

  private
  def self.parent_id
    "visas-immigration"
  end

  def self.new_sections
    [
      ["long-visit-visas", "Long visit visas", "Visiting the UK for 6 months or more"],
      ["settling-in-the-uk", "Settling in the UK", "Getting indefinite leave to remain"],
      ["eu-eea-commonwealth", "EU, EEA and Commonwealth", "UK residence cards, EEA family permits, UK Ancestry visas"],
      ["immigration-appeals", "Immigration appeals and legal advice", "Appeal against a visa, settlement or asylum decision, legal advice"],
      ["stateless", "Stateless", "Stay in the UK if you're stateless, Home Office travel documents"]
    ]
  end

  def self.renamed_sections
    [
      ["visit-visas", "short-visit-visas", "Short visit visas"],
      ["working-visas", "work-visas", "Work visas"],
      ["employers-sponsorship", "sponsoring-workers-students", "Sponsoring workers or students"],
      ["your-visa", "after-youve-applied", "After you've applied"],
    ]
  end
end
