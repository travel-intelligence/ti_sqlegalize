# encoding: utf-8
TiSqlegalize::Engine.routes.draw do
  get '/profile', to: redirect('/profile.txt')

  resources :queries, only: [:create, :show]

  namespace 'v2' do
    resource :entry, only: [:show]
    resources :queries, only: [:create, :show] do
      get 'result', to: 'relations#show_by_query'
      get 'result/heading/:attr_id', to: 'headings#show_by_query', as: 'result_heading'
      get 'result/body', to: 'bodies#show_by_query'
    end
    resources :schemas, only: [:index, :show] do
      get 'relations', to: 'relations#index_by_schema'
    end
    resources :domains, only: [:show] do
      get 'relations', to: 'relations#index_by_domain'
    end
    resources :relations, only: [:show] do
      get 'heading/:attr_id', to: 'headings#show_by_relation', as: 'heading'
      get 'body', to: 'bodies#show_by_relation'
    end
  end
end
