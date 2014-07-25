Panopticon::Application.routes.draw do
  # This is necessary to support some whitehall artefacts with a locale extension on the end
  # of the slug.  If we just blanket allow . in the slug, this interferes with the formatted
  # routes, so this instead special cases the 3 variants of locale extensions (.fr, .zh-hk, .es-419)
  artefact_id_regex = %r{
    [^\.]+                # 1 or more non-dot characters
    (\.[a-z]{2}           # optionally dot followed by a basic locale (eg 'fr')
      (                     # optionally followed by a locale extension
        -[a-z]{2} |           # eg zh-hk
        -\d{3}                # eg es-419
      )?
    )?
  }x
  resources :artefacts, :constraints => { :id => artefact_id_regex } do
    member do
      get :history
      get :archive
    end
    collection do
      get :search_relatable_items, constraints: { format: :json }
    end
  end
  
  resources :tags do
    member do
      put :publish
    end
  end

  root :to => redirect("/artefacts")
end
