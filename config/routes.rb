Rails.application.routes.draw do
  # Auth
  devise_for :users if Rails.env.test? || Rails.env.development?

  # Health + home
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

  # Public read-only
  resources :branches, only: %i[index show]
  resources :users,    only: %i[index show]

  namespace :payments do
    resources :ach_routings, only: %i[index show], param: :public_id
    # Legacy numeric id → public_id
    get "ach_routings/:id", to: "ach_routings#legacy_redirect", constraints: { id: /\d+/ }
  end

  namespace :system do
    resources :reference_lists, only: %i[index show], param: :public_id do
      resources :reference_values, only: %i[index show], param: :public_id
      get ":id/reference_values/:ref_id",
          to: "reference_values#legacy_redirect",
          constraints: { id: /\d+/, ref_id: /\d+/ }
    end
    resources :reference_values,    only: %i[index show], param: :public_id
    resources :country_currencies,  only: %i[index show], param: :public_id
    resources :naics_codes,         only: %i[index show], param: :public_id

    # Legacy single-resource redirects
    get "reference_lists/:id",    to: "reference_lists#legacy_redirect",    constraints: { id: /\d+/ }
    get "reference_values/:id",   to: "reference_values#legacy_redirect",   constraints: { id: /\d+/ }
    get "country_currencies/:id", to: "country_currencies#legacy_redirect", constraints: { id: /\d+/ }
    get "naics_codes/:id",        to: "naics_codes#legacy_redirect",        constraints: { id: /\d+/ }
  end

  # Admin: full CRUD
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

    namespace :payments do
      resources :ach_routings, param: :public_id
    end
  end

  # Engines
  mount ActiveStorage::Engine => "/rails/active_storage"
  mount LetterOpenerWeb::Engine => "/admin/letter_opener" if Rails.env.development?
end
