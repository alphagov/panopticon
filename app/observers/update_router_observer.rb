class UpdateRouterObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    RoutableArtefact.new(artefact).submit if artefact.live?

    unless artefact.owning_app == 'whitehall'
      # Relying on current behaviour where this does not raise errors
      # if done more than once, or done on artefacts never put live
      RoutableArtefact.new(artefact).delete if artefact.archived?
    end
  end
end
