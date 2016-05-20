TiSqlegalize::Engine.routes.draw do
  get '/profile', to: redirect('/profile.txt')

  resources :queries, only: [:create, :show]

  namespace 'v2' do
    resource :entry, only: [:show]
    resources :queries, only: [:create, :show]
    resources :schemas, only: [:index, :show]
  end
end
