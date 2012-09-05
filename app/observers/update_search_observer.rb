class UpdateSearchObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    RummageableArtefact.new(artefact).submit if artefact.live?
    # Relying on current behaviour where this does not raise errors
    # if done more than once, or done on artefacts never put live
    RummageableArtefact.new(artefact).delete if artefact.archived?
  end
end
