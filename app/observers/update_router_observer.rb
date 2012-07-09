class UpdateRouterObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    RouteableArtefact.new(artefact).submit if artefact.live?
  end
end
