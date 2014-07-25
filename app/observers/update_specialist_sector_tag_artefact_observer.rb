class UpdateSpecialistSectorTagArtefactObserver < Mongoid::Observer
  observe :tag

  def after_update(tag)
    update_artefact(tag) if tag.tag_type == 'specialist_sector'
  end

private
  def update_artefact(tag)
    artefact = Artefact.where(kind: 'specialist_sector', slug: tag.tag_id).first
    artefact.update_attributes(name: tag.title, state: tag.state) if artefact
  end
end
