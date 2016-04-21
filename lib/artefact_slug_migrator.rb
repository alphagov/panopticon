class ArtefactSlugMigrator

  attr_reader :logger

  def initialize(logger = nil)
    @logger = logger || Logger.new(STDOUT)
  end

  def run
    logger.info "Migrating slugs for #{slugs.size} artefacts"

    slugs.each do |slug, new_slug|
      artefact = Artefact.where(slug: slug).first
      if artefact
        artefact.skip_update_search = true
        artefact.update_attribute(:slug, new_slug)

        begin
          rummageable_artefact = RummageableArtefact.new(artefact)
          rummageable_artefact.delete
        rescue e
          logger.error "Could not remove artefact from search -> #{e}"
        end

        logger.info "     #{slug} -> #{new_slug}"
      else
        logger.error "Artefact not found with slug #{slug}"
      end
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
