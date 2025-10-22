# config/routes.rb
Rails.application.routes.draw do
  # -------- Authentication --------
  # Keep current behavior: Devise routes only in dev/test.
  # Change to `devise_for :users` if you need login in production.
  devise_for :users if Rails.env.test? || Rails.env.development?

  # -------- Health + Root --------
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

  # Shared UUID constraint used for public_id params
  UUID_REGEX = /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/i

  # -------- Public read-only resources --------
  resources :branches, only: %i[index show]

  # ------ Payments (public, read-only) ------
  namespace :payments do
    # Legacy numeric ID redirect MUST come before resource routes
    get "ach_routings/:id", to: "ach_routings#legacy_redirect", constraints: { id: /\d+/ }

    resources :ach_routings,
              only: %i[index show],
              param: :public_id,
              constraints: { public_id: UUID_REGEX }
  end

  # ------ System (public, read-only) ------
  namespace :system do
    # Legacy single-resource redirects FIRST to avoid being captured by :show
    get "reference_lists/:id",    to: "reference_lists#legacy_redirect",    constraints: { id: /\d+/ }
    get "reference_values/:id",   to: "reference_values#legacy_redirect",   constraints: { id: /\d+/ }
    get "country_currencies/:id", to: "country_currencies#legacy_redirect", constraints: { id: /\d+/ }
    get "naics_codes/:id",        to: "naics_codes#legacy_redirect",        constraints: { id: /\d+/ }

    # Nested legacy redirect for list + value numeric IDs
    get "reference_lists/:id/reference_values/:ref_id",
        to: "reference_values#legacy_redirect",
        constraints: { id: /\d+/, ref_id: /\d+/ }

    # Reference lists and values, read-only. Shallow to allow /system/reference_values/:public_id
    resources :reference_lists,
              only: %i[index show],
              param: :public_id,
              constraints: { public_id: UUID_REGEX },
              shallow: true do
      resources :reference_values,
                only: %i[index show],
                param: :public_id,
                constraints: { public_id: UUID_REGEX }
    end

    resources :country_currencies,
              only: %i[index show],
              param: :public_id,
              constraints: { public_id: UUID_REGEX }

    resources :naics_codes,
              only: %i[index show],
              param: :public_id,
              constraints: { public_id: UUID_REGEX }
  end

  # -------- Admin: full CRUD --------
  namespace :admin do
    root "dashboard#index"

    resources :branches
    resources :users

    namespace :system do
      # Nest values under lists for new/create; shallow for edit/show/destroy
      resources :reference_lists, param: :public_id, constraints: { public_id: UUID_REGEX } do
        resources :reference_values,
                  param: :public_id,
                  constraints: { public_id: UUID_REGEX },
                  shallow: true
      end

      resources :naics_codes,        param: :public_id, constraints: { public_id: UUID_REGEX }
      resources :country_currencies, param: :public_id, constraints: { public_id: UUID_REGEX }
    end

    namespace :payments do
      resources :ach_routings, param: :public_id, constraints: { public_id: UUID_REGEX }
    end
  end

  # -------- Rails Engines --------
  mount ActiveStorage::Engine => "/rails/active_storage"
  mount LetterOpenerWeb::Engine => "/admin/letter_opener" if Rails.env.development?
end
