class ArtefactSlugMigrator

  attr_reader :logger

  def initialize(logger = nil)
    @logger = logger || Logger.new(STDOUT)
  end

  def run
    logger.info "Migrating slugs for #{slugs.size} artefacts"
    slugs.each do |slug, new_slug|
      artefact = Artefact.where(slug: slug).first
      raise "Artefact not found with slug #{slug}" if artefact.nil?

      rummageable_artefact = RummageableArtefact.new(artefact)
      rummageable_artefact.delete

      artefact.update_attribute(:slug, new_slug)

      logger.info "     #{slug} -> #{new_slug}"
    end
    logger.info "Sequence complete."
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
