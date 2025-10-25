# config/routes.rb
# new
Rails.application.routes.draw do
  # ---- Auth ----
  devise_for :users if Rails.env.development? || Rails.env.test?

  # ---- Health + Root ----
  get "up", to: "rails/health#show", as: :rails_health_check
  get "home/index", to: "home#index"
  authenticated(:user)   { root "home#index",            as: :authenticated_root }
  unauthenticated(:user) { root "devise/sessions#new",   as: :unauthenticated_root }

  # ---- Helpers ----
  UUID = /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/i
  ISO2 = /\A[A-Z]{2}\z/
  ISO3 = /\A[A-Z]{3}\z/
  REGION_CODE = /\A[A-Z0-9\-]{1,10}\z/
  ISO_REGION = /\A[A-Z]{2}-[A-Z0-9\-]{1,10}\z/
  REF_CODE = /[A-Za-z0-9._-]+/
  NAICS_VER = /\A20\d{2}\z/
  NAICS_CODE = /\A\d{2,6}\z/

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
    get "naics/:version",                    to: "naics_codes#index", as: :naics_version, constraints: { version: NAICS_VER }
    get "naics/:version/:code",              to: "naics_codes#show",  as: :naics_code,    constraints: { version: NAICS_VER, code: NAICS_CODE }
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
      resources :country_currencies, only: %i[index create]
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
