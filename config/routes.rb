Rails.application.routes.draw do
  get 'movies/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :books, only: [:index, :create, :destroy, :update]
      resources :movies, only: [:index, :create, :destroy, :update]
      resources :series, only: [:index, :create, :destroy, :update]
      resources :anime, only: [:index, :create, :destroy, :update]
      resources :author, only: [:index, :create, :destroy, :update]
      resources :director, only: [:index, :create, :destroy, :update]
      resources :genres, only: [:index, :create, :destroy, :update]
      resources :reviews, only: [:index, :create, :destroy, :update]
      resources :authentication, only: [:index,  :destroy, :update]
      post 'authentication/register', to: 'authentication#register'
      post 'authentication/login', to: 'authentication#create'

      get 'series/genres', to: 'series#unique_genres'
      get 'anime/genres', to: 'anime#unique_genres'
      get 'books/genres', to: 'books#unique_genres'
      get 'movies/genres', to: 'movies#unique_genres'
      get 'books/find', to: 'books#find'
      get 'anime/find', to: 'anime#find'
      get 'movies/find', to: 'movies#find'
      get 'reviews/find', to: 'reviews#find'
      get 'series/find', to: 'series#find'
    end
  end
  # Defines the root path route ("/")
  # root "articles#index"
end
