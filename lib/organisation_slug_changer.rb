class OrganisationSlugChanger
  def initialize(old_slug, new_slug, logger = nil)
    @old_slug = old_slug
    @new_slug = new_slug
    @logger = logger || Logger.new(nil)
  end

  def call
    if organisation.present?
      change_organisation_slug
    else
      logger.info "No organisation tag found with id #{old_slug}, skipping..."
    end
  end

  def change_organisation_slug
    update_organisation_slug
    update_associated_artefacts
    reindex_updated_artefacts
  end

private
  attr_reader(
    :old_slug,
    :new_slug,
  )

  def organisation
    @organisation ||= Tag.where(:tag_id => old_slug, :tag_type => 'organisation').first
  end

  def associated_artefacts
    Artefact.where(:tag_ids => old_slug)
  end

  def update_associated_artefacts
    associated_artefacts.each { |a| update_artefact(a) }
  end

  def reindexable_artefacts
    Artefact.where(:state => 'live', :tag_ids => new_slug, :owning_app.ne => 'whitehall')
  end

  def update_organisation_slug
    organisation.update_attributes!(:tag_id => new_slug)
    logger.info "Renamed #{old_slug} => #{new_slug}"
  end

  def update_artefact(artefact)
    artefact.organisation_ids = (artefact.organisation_ids - [old_slug] + [new_slug])
    artefact.save!
    logger.info "   -> Updated tags for #{artefact.slug}"
  end

  def reindex_artefact(artefact)
    RummageableArtefact.new(artefact).submit
    logger.info "   -> Reindexed #{artefact.slug}"
  end

  def reindex_updated_artefacts
    logger.info "Reindexing #{reindexable_artefacts.count} updated artefacts in search"
    reindexable_artefacts.each { |a| reindex_artefact(a) }
  end
end
