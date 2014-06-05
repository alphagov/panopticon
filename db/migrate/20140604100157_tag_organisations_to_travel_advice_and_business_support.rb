class TagOrganisationsToTravelAdviceAndBusinessSupport < Mongoid::Migration
  def self.up
    add_organisation_tags_to_artefacts(
      non_archived_artefacts_of_kind('travel-advice'),
      'foreign-commonwealth-office'
    )

    add_organisation_tags_to_artefacts(
      non_archived_artefacts_of_kind('business_support'),
      'department-for-business-innovation-skills'
    )
  end

  def self.down
    remove_organisation_tags_from_artefacts(
      non_archived_artefacts_of_kind('travel-advice'),
      'foreign-commonwealth-office'
    )

    remove_organisation_tags_from_artefacts(
      non_archived_artefacts_of_kind('business_support'),
      'department-for-business-innovation-skills'
    )
  end

private
  def self.non_archived_artefacts_of_kind(kind)
    Artefact.of_kind(kind).where(:state.ne => 'archived')
  end

  def self.add_organisation_tags_to_artefacts(artefacts, tag_id)
    puts "Tagging #{artefacts.size} artefacts with organisation '#{tag_id}'"

    longest_slug_length = artefacts.max_by {|a| a.slug.length }.slug.length

    artefacts.each do |artefact|
      print "#{artefact.slug.ljust(longest_slug_length+5)}"

      # append the tag id and then run uniq over the array
      artefact.organisation_ids = (artefact.organisation_ids + [tag_id]).uniq

      if artefact.save
        print "Added"
      else
        print "Error\n"
        print artefact.errors.full_messages.join("\n\t\t")
      end

      print "\n"
    end
  end

  def self.remove_organisation_tags_from_artefacts(artefacts, tag_id)
    puts "Removing organisation '#{tag_id}' from #{artefacts.size} artefacts"

    longest_slug_length = artefacts.max_by {|a| a.slug.length }.slug.length

    artefacts.each do |artefact|
      print "#{artefact.slug.ljust(longest_slug_length+5)}"

      # remove the tag id and reassign to organisation_ids
      artefact.organisation_ids = (artefact.organisation_ids - [tag_id])

      if artefact.save
        print "Removed"
      else
        print "Error\n"
        print artefact.errors.full_messages.join("\n\t\t")
      end

      print "\n"
    end
  end
end
