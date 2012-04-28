Panopticon::Application.routes.draw do
  resources :artefacts
  resources :registrations, only: :create

  match 'google_insight' => 'seo#show'

  root :to => redirect("/artefacts")
end
