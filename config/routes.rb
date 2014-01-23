Panopticon::Application.routes.draw do
  resources :artefacts, :constraints => { :id => /[^\.]+/ }
  resources :browse_sections
  resources :sections
  resources :section_modules

  match 'google_insight' => 'seo#show'
  root :to => redirect("/artefacts")
end
