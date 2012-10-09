Panopticon::Application.routes.draw do
  resources :artefacts, :constraints => { :id => /[^\.]+/ }
  resources :tags, :defaults => {:format => 'json'}

  match 'tags/:id' => 'tags#show', :id =>  /[^\.]+/, :defaults => {:format => 'json'}

  match 'google_insight' => 'seo#show'
  match 'curated_list' => 'curated_list#import'
  match 'curated_list/create' => 'curated_list#create'
  root :to => redirect("/artefacts")
end
