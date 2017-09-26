require 'api_constraints'

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json }, constraints: { subdomain: 'api' }, path: '/'  do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users, only: :show
    end
  end
  resources :team_stats
  resources :player_stats
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root to: 'home#index'
  resources :users, only: %i[show index]
  post 'users/upvote'
  post 'users/downvote'
  post 'users/unvote'
  get 'profile', to: 'users#show'
  get 'test', to: 'home#index2'
  get 'faq', to: 'home#faq'
  get 'kota', to: 'home#kota'
  get 'kurt', to: 'home#kurt'
  get 'brian', to: 'home#brian'
  get 'alex', to: 'home#alex'
  get 'brock', to: 'home#brock'
  get 'application_error', to: 'home#application_error'
  get 'site_stats', to: 'home#site_stats'
  resources :microposts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end
