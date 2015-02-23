TiSqlegalize::Engine.routes.draw do
  get '/profile', to: redirect('/profile.txt')
  resources :queries, only: [:create, :show]
end
