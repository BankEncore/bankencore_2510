# config/routes.rb
Rails.application.routes.draw do
  devise_for :users if Rails.env.test? || Rails.env.development?

  get "up", to: "rails/health#show", as: :rails_health_check
  get "home/index", to: "home#index"

  authenticated :user do
    root "home#index", as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root "devise/sessions#new", as: :unauthenticated_root
    end
  end

  resources :branches, only: %i[index show]
  resources :users,    only: %i[index show]

  namespace :admin do
    root "dashboard#index"

    resources :branches
    resources :users

    namespace :system do
      resources :reference_lists,    param: :public_id
      resources :reference_values,   param: :public_id
      resources :naics_codes,        param: :public_id
      resources :country_currencies, param: :public_id
    end
  end

  namespace :payments do
    resources :ach_routings, param: :public_id
  end

  namespace :system do
    resources :reference_lists, param: :public_id do
      resources :reference_values, param: :public_id
    end
    resources :country_currencies
    resources :naics_codes, only: %i[index show new create edit update destroy]
  end

  mount LetterOpenerWeb::Engine => "/letter_opener" if Rails.env.development?
end
