Rails.application.routes.draw do

  resources :team_stats
  resources :player_stats
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy' 
  end
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: 'home#index'
  resources :users, only: [:show, :index] 
  get 'profile', to: 'users#show'
  get 'test', to: 'home#index2'
  get 'faq', to: 'home#faq'
  get 'kota', to: 'home#kota'
  get 'kurt', to: 'home#kurt'
  get 'brian', to: 'home#brian'
  get 'alex', to: 'home#alex'
  resources :microposts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
