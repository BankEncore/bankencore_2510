  # config/routes.rb
  # new

  # ---- Helpers ----

  UUID       = /[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}/i unless defined?(UUID)
  ISO2       = /[A-Z]{2}/i      unless defined?(ISO2)
  ISO3       = /[A-Z]{3}/i      unless defined?(ISO3)
  REGION     = /[A-Z0-9-]{1,10}/i unless defined?(REGION)
  ISO_REGION = /[A-Z]{2}-[A-Z0-9-]{1,10}/i unless defined?(ISO_REGION)
  REF_CODE   = /[A-Za-z0-9._-]+/ unless defined?(REF_CODE)
  NAICS_VER  = /20\d{2}/         unless defined?(NAICS_VER)
  NAICS_CODE = /\d{2,6}/         unless defined?(NAICS_CODE)

Rails.application.routes.draw do
  # ---- Auth ----
  # Register Devise routes for users in all environments. The unauthenticated
  # root routes to Devise's sessions#new, so Devise mappings must be present
  # in production/staging as well.
  devise_for :users

  # ---- Health + Root ----
  get "up", to: "rails/health#show", as: :rails_health_check
  get "home/index", to: "home#index"
  # Use a single unconditional root that performs authentication-based
  # redirects inside the controller. Avoids Devise route constraints at
  # routing time which can fail when middleware (Warden) isn't available.
  root "home#index"

  # ===================== Public =====================

  # Branches (public_id)
  resources :branches, only: %i[index show], param: :public_id, constraints: { public_id: UUID }

  # Payments ACH (public_id)
  namespace :payments do
    resources :ach_routings, only: %i[index show], param: :public_id, constraints: { public_id: UUID }
  end

  # System lookups (natural keys)
  namespace :system do
    # Reference lists and values
    resources :reference_lists, only: %i[index show], param: :key, constraints: { key: REF_CODE } do
      resources :reference_values, only: %i[index show], param: :code, constraints: { code: REF_CODE }
    end

    # Countries, Regions, Currencies
    resources :countries,  only: %i[index show], param: :alpha2, constraints: { alpha2: ISO2 }
    resources :currencies, only: %i[index show], param: :code,   constraints: { code: ISO3 }

    # Regions by ISO-3166-2 (e.g., US-PA)
    resources :regions, only: %i[index show], param: :iso_code, constraints: { iso_code: ISO_REGION }

    # CountryCurrencies by composite key (e.g., US-USD)
    get "country_currencies", to: "country_currencies#index"
    get "country_currencies/:country_alpha2-:currency_code",
        to: "country_currencies#show",
        as: :country_currency,
        constraints: { country_alpha2: ISO2, currency_code: ISO3 }

    # NAICS by version + code
    get "naics/:version",       to: "naics_codes#index", as: :naics_version
    get "naics/:version/:code", to: "naics_codes#show",  as: :naics_code
  end

  # ===================== Admin =====================

  namespace :admin do
    root "dashboard#index"

    # Users, Branches (public_id)
    resources :users,    param: :public_id, constraints: { public_id: UUID }
    resources :branches, param: :public_id, constraints: { public_id: UUID }

    # Payments ACH (public_id)
    namespace :payments do
      resources :ach_routings, param: :public_id, constraints: { public_id: UUID }
    end

    # System admin CRUD (natural keys)
    namespace :system do
      resources :reference_lists, param: :key, constraints: { key: REF_CODE } do
        resources :reference_values, param: :code, constraints: { code: REF_CODE }
      end

      resources :countries,  param: :alpha2, constraints: { alpha2: ISO2 }
      resources :currencies, param: :code,   constraints: { code: ISO3 }

      resources :regions, param: :iso_code, constraints: { iso_code: ISO_REGION }

      # NAICS CRUD grouped by version
      scope "naics/:version", constraints: { version: NAICS_VER } do
        get   "/",              to: "naics_codes#index", as: :naics_codes
        post  "/",              to: "naics_codes#create"
        get   "/new",           to: "naics_codes#new",   as: :new_naics_code
        get   "/:code/edit",    to: "naics_codes#edit",  as: :edit_naics_code, constraints: { code: NAICS_CODE }
        get   "/:code",         to: "naics_codes#show",  as: :naics_code_admin, constraints: { code: NAICS_CODE }
        patch "/:code",         to: "naics_codes#update",                      constraints: { code: NAICS_CODE }
        put   "/:code",         to: "naics_codes#update",                      constraints: { code: NAICS_CODE }
        delete "/:code",        to: "naics_codes#destroy",                     constraints: { code: NAICS_CODE }
      end

  # CountryCurrencies CRUD by composite key
  # include :new so the `new_admin_system_country_currency_path` helper exists
  resources :country_currencies, only: %i[index new create]
      get    "country_currencies/:country_alpha2-:currency_code", to: "country_currencies#show",    as: :country_currency,    constraints: { country_alpha2: ISO2, currency_code: ISO3 }
      get    "country_currencies/:country_alpha2-:currency_code/edit", to: "country_currencies#edit",   as: :edit_country_currency, constraints: { country_alpha2: ISO2, currency_code: ISO3 }
      patch  "country_currencies/:country_alpha2-:currency_code", to: "country_currencies#update",  constraints: { country_alpha2: ISO2, currency_code: ISO3 }
      put    "country_currencies/:country_alpha2-:currency_code", to: "country_currencies#update",  constraints: { country_alpha2: ISO2, currency_code: ISO3 }
      delete "country_currencies/:country_alpha2-:currency_code", to: "country_currencies#destroy", constraints: { country_alpha2: ISO2, currency_code: ISO3 }
    end
  end

  # ---- Engines ----
  mount ActiveStorage::Engine => "/rails/active_storage"
  mount LetterOpenerWeb::Engine => "/admin/letter_opener" if Rails.env.development?
end
