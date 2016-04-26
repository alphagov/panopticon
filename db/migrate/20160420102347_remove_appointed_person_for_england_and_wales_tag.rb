class RemoveAppointedPersonForEnglandAndWalesTag < Mongoid::Migration
  def self.up
    organisation_tag = Tag.where(tag_type: 'organisation', tag_id: 'appointed-person-for-england-and-wales-under-the-proceeds-of-crime-act-2002').first
    if organisation_tag.present?
      Artefact.where(tag_ids: organisation_tag.tag_id).each do |tagged_document|
        print "#{artefact.slug}: "
        tagged_document.organisation_ids = (tagged_document.organisation_ids - [organisation_tag.tag_id])

        if tagged_document.save
          print "Removed"
        else
          print "Error\n"
          print tagged_document.errors.full_messages.join("\n\t\t")
        end
        print "\n"
        RummageableArtefact.new(tagged_document).submit
      end

      organisation_tag.destroy
    end
  end

  def self.down
    # This org was created in error, there's no need for a down to re-instate it
  end
end
