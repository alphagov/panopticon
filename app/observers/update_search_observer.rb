class UpdateSearchObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    RummageableArtefact.new(artefact).submit if artefact.live?
    RummageableArtefact.new(artefact).delete if artefact.archived?
  end
end
