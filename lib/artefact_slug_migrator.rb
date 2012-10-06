class ArtefactSlugMigrator
  def run
    slugs.each do |slug, new_slug|
      artefact = Artefact.where(slug: slug).first
      raise "Artefact not found with slug #{slug}" if artefact.nil?

      rummageable_artefact = RummageableArtefact.new(artefact)
      rummageable_artefact.delete

      artefact.slug = new_slug
      artefact.save!
    end
  end

  private
    def slugs
      @slugs ||= load_slugs
    end

    def load_slugs
      json = File.open(Rails.root.join('data','slugs_to_migrate.json')).read
      JSON.parse(json) || [ ]
    end
end
