# config/routes.rb
Rails.application.routes.draw do
  # Health + root
  get  "up", to: "rails/health#show", as: :rails_health_check
  root "home#index"

  # Payments
  namespace :payments do
    uuid = { public_id: /\A[0-9a-f-]{36}\z/i }
    resources :ach_routings, param: :public_id, constraints: uuid
  end

  # System
  namespace :system do
    uuid = { public_id: /\A[0-9a-f-]{36}\z/i }

    resources :reference_lists, param: :public_id, constraints: uuid, shallow: true do
      resources :reference_values, param: :public_id, constraints: uuid
    end

    resources :country_currencies
    resources :naics_codes, only: [ :index, :show ]
  end
end
