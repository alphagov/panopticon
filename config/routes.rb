Panopticon::Application.routes.draw do
  resources :artefacts, :constraints => { :id => /[^\.]+/ }
  resources :tags

  match 'categories' => 'tags#categories', :as => :categories
  match 'google_insight' => 'seo#show'
  match 'curated_list' => 'curated_list#import', :as => :curated_list
  match 'curated_list/create' => 'curated_list#create'
  root :to => redirect("/artefacts")
end
