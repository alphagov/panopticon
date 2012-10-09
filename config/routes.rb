Panopticon::Application.routes.draw do
  resources :artefacts, :constraints => { :id => /[^\.]+/ }
  resources :tags, :defaults => {:format => 'json'}

  match 'tags/:id' => 'tags#show', :id =>  /[^\.]+/, :defaults => {:format => 'json'}

  match 'google_insight' => 'seo#show'

  root :to => redirect("/artefacts")
end
