Panopticon::Application.routes.draw do
  resources :slugs
  resources :artefacts

  match 'google_insight' => 'seo#show'
end
