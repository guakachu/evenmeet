Rails.application.routes.draw do
  root to: "pages#home"

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "radar",     to: "participations#radar"
  get "dashboard", to: "pages#dashboard"
  get "events/current", to: "events#current", as: :current_event

  get "challenges/:id/rewards", to: "rewards#show", as: :reward
  get "challenges/:id/rewards/qrcode", to: "rewards#qrcode"
  get "challenges/:id/rewards/scan", to: "rewards#scan", as: :scan

  resources :participations, only: %i[update]

  resources :events do
    resources :participations, only: %i[new create]
    resources :relationships, only: %i[new create]
  end

  resources :participations, only: %i[show index] do
    resources :relationships, only: %i[new create]
  end

  resources :challenges, only: %i[show index] do
    resources :messages, only: :create
  end

  resources :challenges, only: :show do
    resources :messages, only: :create
  end
end
