class UpdateRouterObserver < Mongoid::Observer
  observe :artefact

  def after_save(artefact)
    RoutableArtefact.new(artefact).submit if artefact.live?

    unless artefact.owning_app == 'whitehall'
      if artefact.archived?
        if artefact.redirect_url.blank?
          RoutableArtefact.new(artefact).delete
        else
          RoutableArtefact.new(artefact).redirect(artefact.redirect_url)
        end
      end
    end
  end
end
