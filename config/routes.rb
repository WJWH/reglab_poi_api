Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/healthcheck', to: 'healthcheck#index'

  post '/search', to: 'search#show'
end
