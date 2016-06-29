Rails.application.routes.draw do
  resources :businesses

  root 'businesses#index'
  get '/filter', to: 'businesses#filter'
end
