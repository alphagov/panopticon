class UpdateRouterObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    RoutableArtefact.new(artefact).submit
  end
end
