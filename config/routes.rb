Rails.application.routes.draw do
  devise_for :users

  root to: "homes#top"
  get '/home/about' => "homes#about", as: "about"
  get 'relationships/followings'
  get 'relationships/followers'
  get 'search' => 'searches#search'

  resources :books, only:[:index,:show,:edit,:create,:destroy,:update] do
    resource :favorites, only: [:create, :destroy]
    resources :book_comments, only: [:create, :destroy]
  end

  resources :users, only:[:index,:show,:edit,:update] do
    resource :relationships, only:[:create, :destroy]
    get 'followings' => 'relationships#followings', as: 'followings'
    get 'followers' => 'relationships#followers', as: 'followers'
  end

#ゲストログイン機能
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

