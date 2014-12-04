class UpdateSpecialistSectorTagArtefactObserver < Mongoid::Observer
  observe :tag

  def after_update(tag)
    if tag.tag_type == 'specialist_sector'
      update_artefact(tag)
      reindex_tagged_documents(tag) if tag.state_changed? && tag.live?
    end
  end

private

  def reindex_tagged_documents(tag)
    Panopticon.whitehall_admin_api.reindex_specialist_sector_editions(tag.tag_id)
    Panopticon.publisher_api.reindex_topic_editions(tag.tag_id)
  end

  def update_artefact(tag)
    artefact = Artefact.where(kind: 'specialist_sector', slug: tag.tag_id).first
    artefact.update_attributes(name: tag.title, state: tag.state) if artefact
  end
end
