Rails.application.routes.draw do
  resources :memes do
    resources :commands
    resources :tags
  end
  resources :sessions
  get '/auth/:provider/callback', to: 'sessions#create'
  root to: 'memes#index'
end
