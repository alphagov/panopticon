Panopticon::Application.routes.draw do
  resources :artefacts, :constraints => { :id => /[^\.]+/ }
  resources :browse_sections
  resources :tags

  match 'tags/:id' => 'tags#show', :id =>  /[^\.]+/, :defaults => {:format => 'json'}
  match 'categories' => 'tags#categories', :as => :categories
  match 'google_insight' => 'seo#show'
  root :to => redirect("/artefacts")
end
