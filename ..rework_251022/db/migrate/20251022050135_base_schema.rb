# db/migrate/20251022050135_base_schema.rb
# new
# frozen_string_literal: true
class BaseSchema < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # ========== REFERENCES (natural keys) ==========
    create_table :system_reference_lists do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :system_reference_lists, :key, unique: true

    create_table :system_reference_values do |t|
      t.references :reference_list, null: false, foreign_key: { to_table: :system_reference_lists }
      t.string :code, null: false
      t.string :name, null: false
      t.string :short_name
      t.text :description
      t.integer :sort_index, null: false, default: 50
      t.boolean :active, null: false, default: true
      t.string :external_code
      t.jsonb :metadata, null: false, default: {}
      t.date :valid_from
      t.date :valid_to
      t.timestamps
    end
    add_index :system_reference_values, [:reference_list_id, :code], unique: true, name: :idx_srv_on_list_code

    # ========== STANDARDS ==========
    create_table :system_countries do |t|
      t.string :alpha2,  null: false, limit: 2
      t.string :alpha3,  null: false, limit: 3
      t.string :numeric, null: false, limit: 3
      t.text   :iso_short_name, null: false
      t.text   :iso_long_name
      t.text   :dialing_prefix
      t.boolean :postal_code_required, null: false, default: true
      t.text   :postal_code_regex
      t.text   :address_format
      t.string :currency_primary_code, limit: 3
      t.jsonb  :metadata, null: false, default: {}
      t.boolean :active,  null: false, default: true
      t.timestamps
    end
    add_index :system_countries, :alpha2,  unique: true
    add_index :system_countries, :alpha3,  unique: true
    add_index :system_countries, :numeric, unique: true
    add_index :system_countries, :currency_primary_code

    create_table :system_regions do |t|
      t.string :country_alpha2, null: false, limit: 2
      t.string :region_code,    null: false, limit: 10
      t.string :name,           null: false
      t.string :kind,           null: false
      t.string :iso_code,       null: false
      t.boolean :active, null: false, default: true
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :system_regions, [:country_alpha2, :region_code], unique: true
    add_index :system_regions, :iso_code, unique: true
    add_foreign_key :system_regions, :system_countries, column: :country_alpha2, primary_key: :alpha2

    create_table :system_naics_codes do |t|
      t.string :code, null: false
      t.string :title, null: false
      t.text :description
      t.string :parent_code
      t.integer :level, null: false
      t.string :version, null: false, default: "2022"
      t.string :sector, limit: 2
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :system_naics_codes, [:version, :code], unique: true
    add_index :system_naics_codes, :parent_code
    add_index :system_naics_codes, :level

    create_table :system_currencies do |t|
      t.string :code,    null: false, limit: 3
      t.string :numeric, null: false, limit: 3
      t.string :name,    null: false
      t.string :full_name
      t.integer :minor_units, null: false, default: 2
      t.string  :symbol
      t.integer :unicode_codepoint
      t.boolean :active, null: false, default: true
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :system_currencies, :code,    unique: true
    add_index :system_currencies, :numeric, unique: true

    create_table :system_country_currencies do |t|
      t.string :country_alpha2, null: false, limit: 2
      t.string :currency_code,  null: false, limit: 3
      t.boolean :is_primary,   null: false, default: false
      t.boolean :legal_tender, null: false, default: true
      t.date :valid_from
      t.date :valid_to
      t.timestamps
    end
    add_index :system_country_currencies, [:country_alpha2, :currency_code], unique: true, name: :idx_scc_on_country_currency
    add_foreign_key :system_country_currencies, :system_countries, column: :country_alpha2, primary_key: :alpha2
    add_foreign_key :system_country_currencies, :system_currencies, column: :currency_code, primary_key: :code

    # ========== RBAC ==========
    create_table :roles do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :roles, :key, unique: true

    create_table :permissions do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :permissions, :key, unique: true

    create_table :role_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.timestamps
    end
    add_index :role_permissions, [:role_id, :permission_id], unique: true

    # ========== USERS (public_id) ==========
    create_table :users do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at
      t.string  :first_name,  null: false, default: "", limit: 100
      t.string  :last_name,   null: false, default: "", limit: 100
      t.string  :display_name, limit: 150
      t.string  :locale, limit: 10
      t.string  :phone_e164, limit: 20
      t.string  :time_zone, null: false, default: "UTC", limit: 50
      t.string  :status, null: false, default: "active", limit: 20
      t.boolean :mfa_enabled, null: false, default: false
      t.datetime :terms_accepted_at
      t.jsonb  :preferences, null: false, default: {}
      t.timestamps
    end
    add_index :users, :public_id, unique: true
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :display_name
    add_index :users, :locale

    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end
    add_index :user_roles, [:user_id, :role_id], unique: true

    # ========== BRANCHES (public_id) ==========
    create_table :branches do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :code, null: false, limit: 16
      t.string :name, null: false, limit: 120
      t.integer :status, null: false, default: 1
      t.string  :time_zone, null: false
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :region_code, limit: 10
      t.string :postal_code, limit: 16
      t.string :country_alpha2, limit: 2, null: false
      t.string :phone, limit: 32
      t.string :fax,   limit: 32
      t.string :email
      t.jsonb  :operating_hours, null: false, default: {}
      t.decimal :latitude,  precision: 9, scale: 6
      t.decimal :longitude, precision: 9, scale: 6
      t.timestamps
    end
    add_index :branches, :public_id, unique: true
    add_index :branches, :code, unique: true
    add_index :branches, :status
    add_index :branches, [:country_alpha2, :region_code]
    add_foreign_key :branches, :system_countries, column: :country_alpha2, primary_key: :alpha2

    create_table :branch_memberships do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.timestamps
    end
    add_index :branch_memberships, [:user_id, :branch_id], unique: true

    # ========== PAYMENTS::ACH (public_id) ==========
    create_table :payments_ach_routings do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :routing_number,       null: false, limit: 9
      t.string :customer_name,        null: false, limit: 36
      t.string :city,                              limit: 25
      t.string :state_code,                        limit: 2
      t.string :servicing_frb_number,              limit: 9
      t.string :office_code,                       limit: 1
      t.string :record_type_code,                  limit: 1
      t.string :institution_status_code,           limit: 1
      t.string :data_view_code,                    limit: 1
      t.string :new_routing_number,                limit: 9
      t.timestamps
    end
    add_index :payments_ach_routings, :public_id, unique: true
    add_index :payments_ach_routings, :routing_number, unique: true

    # ========== AUDITS ==========
    create_table :audits, id: :bigserial do |t|
      t.uuid     :request_uuid
      t.string   :auditable_type
      t.bigint   :auditable_id
      t.string   :associated_type
      t.bigint   :associated_id
      t.string   :user_type
      t.bigint   :user_id
      t.string   :username
      t.string   :action, null: false
      t.jsonb    :audited_changes, null: false, default: {}
      t.bigint   :version, null: false, default: 0
      t.string   :comment
      t.string   :remote_address
      t.string   :auditable_name
      t.datetime :created_at, null: false
    end
    add_index :audits, [:auditable_type, :auditable_id, :version], name: "auditable_index"
    add_index :audits, [:associated_type, :associated_id],        name: "associated_index"
    add_index :audits, [:user_id, :user_type],                    name: "user_index"
    add_index :audits, :request_uuid

    # Checks
    reversible do |dir|
      dir.up do
        execute "ALTER TABLE system_currencies ADD CONSTRAINT chk_currency_minor_units CHECK (minor_units IN (0,1,2,3));"
        execute "ALTER TABLE system_country_currencies ADD CONSTRAINT chk_scc_valid_window CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_from <= valid_to);"
        execute "ALTER TABLE branches ADD CONSTRAINT chk_branches_status CHECK (status IN (0,1));"
      end
    end
  end
end
