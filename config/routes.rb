Panopticon::Application.routes.draw do
  # This is necessary to support some whitehall artefacts with a locale extension on the end
  # of the slug.  If we just blanket allow . in the slug, this interferes with the formatted
  # routes, so this instead special cases the 3 variants of locale extensions (.fr, .zh-hk, .es-419)
  # The following regex matches these requirements:
  # - 1 or more non-dot characters
  # - optionally dot followed by a basic locale (eg 'fr')
  # - optionally followed by a locale extension
  artefact_id_regex = %r{
    [^\.]+
    (\.[a-z]{2}
      (
        -[a-z]{2} |
        -\d{3}
      )?
    )?
  }x
  resources :artefacts, :constraints => { :id => artefact_id_regex } do
    member do
      get :history
      get :withdraw
    end
  end

  resources :tags, :constraints => { :id => /[a-zA-Z0-9_\-%\/]+/ } do
    member do
      post :publish
    end
  end

  root :to => redirect("/artefacts")

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
