class WalesOfficeSlugChange < Mongoid::Migration
  OLD_SLUG = 'wales-office'
  NEW_SLUG = 'office-of-the-secretary-of-state-for-wales'

  def self.up
    self.update_org_tag(OLD_SLUG, NEW_SLUG)
  end

  def self.down
    self.update_org_tag(NEW_SLUG, OLD_SLUG)
  end

  def self.update_org_tag(old_tag_id, new_tag_id)
    org = Tag.where(:tag_id => old_tag_id, :tag_type => 'organisation').first
    if org.present?
      org.update_attributes!(:tag_id => new_tag_id)
      puts "Renamed #{old_tag_id} => #{new_tag_id}"

      tagged_artefacts = Artefact.where(:tag_ids => old_tag_id)
      tagged_artefacts.each do |artefact|
        artefact.organisation_ids = (artefact.organisation_ids - [old_tag_id] [new_tag_id])
        artefact.save!
        puts "\t -> Updated tags for #{artefact.slug}"
      end

      puts "Reindexing updated artefacts in search"
      Artefact.where(:state => 'live', :tag_ids => new_tag_id, :owning_app.ne => 'whitehall').each do |artefact|
        RummageableArtefact.new(artefact).submit
        puts "\t -> Reindexed #{artefact.slug}"
      end
    else
      puts "No organisation tag found with id #{old_slug}, skipping..."
    end
  end
end