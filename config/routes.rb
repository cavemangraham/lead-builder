Rails.application.routes.draw do
  resources :businesses, except: [:delete] do
  	collection do
  		delete :remove_all
  	end
  end

  root 'businesses#index'
  get '/filter', to: 'businesses#filter'

end
