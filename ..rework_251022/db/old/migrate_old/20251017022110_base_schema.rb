# frozen_string_literal: true

class BaseSchema < ActiveRecord::Migration[8.0]
  def change
    # ========== SYSTEM REFERENCE BACKBONE ==========
    create_table :system_reference_lists do |t|
      t.uuid    :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string  :key,       null: false
      t.string  :name,      null: false
      t.text    :description
      t.boolean :active,    null: false, default: true
      t.timestamps
    end
    add_index :system_reference_lists, :public_id, unique: true
    add_index :system_reference_lists, :key,       unique: true

    create_table :system_reference_values do |t|
      t.uuid       :public_id,      null: false, default: -> { "gen_random_uuid()" }
      t.references :reference_list, null: false, foreign_key: { to_table: :system_reference_lists }
      t.string  :code,        null: false
      t.string  :name,        null: false
      t.string  :short_name
      t.text    :description
      t.integer :sort_index,  null: false, default: 50
      t.boolean :active,      null: false, default: true
      t.string  :external_code
      t.jsonb   :metadata,    null: false, default: {}
      t.date    :valid_from
      t.date    :valid_to
      t.timestamps
    end
    add_index :system_reference_values, :public_id, unique: true
    add_index :system_reference_values, [ :reference_list_id, :code ], unique: true, name: :idx_srv_on_list_code

    # ========== STANDARDS ==========
    create_table :system_countries do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :alpha2,    null: false, limit: 2
      t.string :alpha3,    null: false, limit: 3
      t.string :numeric,   null: false, limit: 3
      t.string :name,      null: false
      t.jsonb  :metadata,  null: false, default: {}
      t.boolean :active,   null: false, default: true
      t.timestamps
    end
    add_index :system_countries, :public_id, unique: true
    add_index :system_countries, :alpha2,    unique: true
    add_index :system_countries, :alpha3,    unique: true
    add_index :system_countries, :numeric,   unique: true

    create_table :system_regions do |t|
      t.uuid   :public_id,      null: false, default: -> { "gen_random_uuid()" }
      t.string :code,           null: false        # e.g., "US-PA"
      t.string :country_alpha2, null: false, limit: 2
      t.string :local_code,     null: false        # e.g., "PA"
      t.string :name,           null: false
      t.string :type_name
      t.string :parent_code
      t.jsonb  :metadata,       null: false, default: {}
      t.boolean :active,        null: false, default: true
      t.timestamps
    end
    add_index :system_regions, :public_id, unique: true
    add_index :system_regions, :code,      unique: true
    add_index :system_regions, [ :country_alpha2, :local_code ], unique: true
    add_foreign_key :system_regions, :system_countries, column: :country_alpha2, primary_key: :alpha2

    create_table :system_naics_codes do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :code,      null: false             # 2–6 digits
      t.string :title,     null: false
      t.text   :description
      t.string :parent_code
      t.integer :level,    null: false
      t.string  :version,  null: false, default: "2022"
      t.string  :sector,   limit: 2
      t.boolean :active,   null: false, default: true
      t.timestamps
    end
    add_index :system_naics_codes, :public_id, unique: true
    add_index :system_naics_codes, [ :version, :code ], unique: true
    add_index :system_naics_codes, :parent_code
    add_index :system_naics_codes, :level

    create_table :system_currencies do |t|
      t.uuid   :public_id,  null: false, default: -> { "gen_random_uuid()" }
      t.string :code,       null: false, limit: 3   # ISO 4217
      t.string :name,       null: false
      t.integer :minor_units, null: false, default: 2
      t.timestamps
    end
    add_index :system_currencies, :public_id, unique: true
    add_index :system_currencies, :code,      unique: true

    create_table :system_country_currencies do |t|
      t.uuid :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.references :currency, null: false, foreign_key: { to_table: :system_currencies }
      # country FK by alpha2 PK
      t.string :country_id, null: false, limit: 2
      t.date :valid_from
      t.date :valid_to
      t.timestamps
    end
    add_index :system_country_currencies, :public_id, unique: true
    add_index :system_country_currencies, [ :country_id, :currency_id ], unique: true, name: :idx_scc_on_country_currency
    add_foreign_key :system_country_currencies, :system_countries, column: :country_id, primary_key: :alpha2

    # ========== USERS (Devise + app fields merged) ==========
    create_table :users do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      # Devise core
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      # Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      # Rememberable
      t.datetime :remember_created_at
      # Trackable (if you keep it)
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      # App fields
      t.string  :name,              limit: 100
      t.string  :time_zone,         limit: 50,  null: false, default: "UTC"
      t.string  :role,              limit: 30,  null: false, default: "user"
      t.string  :status,            limit: 20,  null: false, default: "active"
      t.boolean :mfa_enabled,                   null: false, default: false
      t.datetime :terms_accepted_at
      t.integer :role_i,                        null: false, default: 0   # enum: read_only(0), staff(1), system_admin(2)
      t.boolean :admin,                         null: false, default: false
      t.timestamps
    end
    add_index :users, :public_id, unique: true
    add_index :users, :email,     unique: true
    add_index :users, :reset_password_token, unique: true

    # ========== BRANCHES ==========
    create_table :branches do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :code,      null: false, limit: 10
      t.string :name,      null: false, limit: 100
      t.string :status,    null: false, default: "active"
      t.timestamps
    end
    add_index :branches, :public_id, unique: true
    add_index :branches, :code,      unique: true

    create_table :branch_memberships do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.timestamps
    end
    add_index :branch_memberships, [ :user_id, :branch_id ], unique: true

    # ========== PAYMENTS::ACH ROUTINGS ==========
    create_table :payments_ach_routings do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :routing_number,       null: false, limit: 9
      t.string :customer_name,        null: false, limit: 36
      t.string :city,                              limit: 25
      t.string :state_code,                        limit: 2  # allowed NULL per prior relaxation
      t.string :servicing_frb_number,              limit: 9
      t.string :office_code,                       limit: 1
      t.string :record_type_code,                  limit: 1
      t.string :institution_status_code,           limit: 1
      t.string :data_view_code,                    limit: 1
      t.string :new_routing_number,                limit: 9
      t.timestamps
    end
    add_index :payments_ach_routings, :public_id,     unique: true
    add_index :payments_ach_routings, :routing_number, unique: true

    # ========== AUDITED (if you use audited gem) ==========
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
    add_index :audits, [ :auditable_type, :auditable_id, :version ], name: "auditable_index"
    add_index :audits, [ :associated_type, :associated_id ],        name: "associated_index"
    add_index :audits, [ :user_id, :user_type ],                    name: "user_index"
    add_index :audits, :request_uuid
  end
end
