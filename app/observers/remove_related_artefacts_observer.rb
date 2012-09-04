class RemoveRelatedArtefactsObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    if artefact.state == 'archived'
      Artefact.where(:related_artefact_ids.in => [artefact.id]).each do | a |
        a.related_artefact_ids.delete(artefact.id)
        a.save
      end
    end
  end
end
