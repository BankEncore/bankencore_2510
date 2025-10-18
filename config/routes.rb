# config/routes.rb
Rails.application.routes.draw do
  get  "up", to: "rails/health#show", as: :rails_health_check
  root "home#index"

  UUID = /[0-9a-f-]{36}/i

  namespace :payments do
    resources :ach_routings, param: :public_id, constraints: { public_id: UUID }
  end

  namespace :system do
    resources :reference_lists, param: :public_id, constraints: { public_id: UUID }, shallow: true do
      resources :reference_values, param: :public_id, constraints: { public_id: UUID }
    end

    resources :country_currencies
    resources :naics_codes, only: [ :index, :show ]
  end
end
