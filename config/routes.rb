Rails.application.routes.draw do
  resources :memes do
    resources :commands
  end
  get '/auth/:provider/callback', to: 'sessions#create'
  root to: "memes#index"
end
