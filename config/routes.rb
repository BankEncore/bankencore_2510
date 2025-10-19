# config/routes.rb
Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :rails_health_check
  get "home/index", to: "home#index"
  root "home#index"

  namespace :admin do
    root "dashboard#index"
  end

  namespace :payments do
    resources :ach_routings, param: :public_id
  end

  namespace :system do
    resources :reference_lists, param: :public_id do
      resources :reference_values, param: :public_id
    end
    resources :country_currencies
    resources :naics_codes, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  end
end
