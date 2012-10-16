class UpdateSearchObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    rummageable_artefact = RummageableArtefact.new(artefact)
    rummageable_artefact.submit if rummageable_artefact.should_be_indexed?
    # Relying on current behaviour where this does not raise errors
    # if done more than once, or done on artefacts never put live
    rummageable_artefact.delete if artefact.archived?
  end
end
