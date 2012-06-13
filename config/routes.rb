Panopticon::Application.routes.draw do
  resources :artefacts
  resources :registrations, only: :create
  resources :tags, :defaults => {:format => 'json'}

  resources :curated_lists, only: :index

  match 'tags/:id' => 'tags#show', :id =>  /[^\.]+/, :defaults => {:format => 'json'}

  match 'google_insight' => 'seo#show'

  root :to => redirect("/artefacts")
end
