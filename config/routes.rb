Rails.application.routes.draw do
  resources :businesses

  root 'businesses#index'
end
