class RemoveDuplicateDetailedGuideArtefacts < Mongoid::Migration
  IGNORED_DIFF_ATTRIBUTES = %w[_id actions updated_at created_at slug business_proposition paths tags]

  def self.up
    Artefact.where(kind: "detailed_guide", slug: %r{^(?!guidance/)}).each do |unmigrated|
      duplicate = Artefact.where(kind: "detailed_guide", slug: "guidance/#{unmigrated.slug}").first
      if duplicate
        diff = duplicate.attributes.except(*IGNORED_DIFF_ATTRIBUTES).diff(
          unmigrated.attributes.except(*IGNORED_DIFF_ATTRIBUTES))

        if diff.any?
          puts "Merging #{unmigrated.slug}:"
          p diff

          unmigrated.attributes = diff
          unmigrated.save!
        end
        unmigrated.actions += duplicate.actions.map { |a| a.action_type = "update"; a }

        duplicate.destroy
      end
      unmigrated.set(:slug, "guidance/#{unmigrated.slug}")
      puts "Moved #{unmigrated.slug}"
    end
  end

  def self.down
  end
end
