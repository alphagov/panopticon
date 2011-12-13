Panopticon::Application.routes.draw do
  resources :artefacts

  match 'google_insight' => 'seo#show'

  root :to => redirect("/artefacts")
end
