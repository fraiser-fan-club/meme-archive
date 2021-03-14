Rails.application.routes.draw do
  resources :memes do
    resources :commands
  end
  resources :sessions
  get '/auth/:provider/callback', to: 'sessions#create'
  root to: "memes#index"
end
