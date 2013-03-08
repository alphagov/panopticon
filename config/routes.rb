Panopticon::Application.routes.draw do
  resources :artefacts, :constraints => { :id => /[^\.]+/ }
  resources :browse_sections

  match 'google_insight' => 'seo#show'
  root :to => redirect("/artefacts")
end
