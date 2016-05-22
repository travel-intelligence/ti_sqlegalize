# encoding: utf-8
TiSqlegalize::Engine.routes.draw do
  get '/profile', to: redirect('/profile.txt')

  resources :queries, only: [:create, :show]

  namespace 'v2' do
    resource :entry, only: [:show]
    resources :queries, only: [:create, :show] do
      get 'result', to: 'relations#show'
      get 'result/heading/:attr_id', to: 'headings#show', as: 'result_heading'
      get 'result/body', to: 'bodies#show'
    end
    resources :schemas, only: [:index, :show]
    resources :domains, only: [:show] do
      get 'relations', to: 'domains#show_relations'
    end
  end
end
