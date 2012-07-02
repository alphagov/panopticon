class UpdateSearchObserver < Mongoid::Observer

  observe :artefact

  def after_save(artefact)
    RummageableArtefact.new(artefact).submit if artefact.live?
  end
end