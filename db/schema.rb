# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_25_214122) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "audits", force: :cascade do |t|
    t.uuid "request_uuid"
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.string "associated_type"
    t.bigint "associated_id"
    t.string "user_type"
    t.bigint "user_id"
    t.string "username"
    t.string "action", null: false
    t.jsonb "audited_changes", default: {}, null: false
    t.bigint "version", default: 0, null: false
    t.string "comment"
    t.string "remote_address"
    t.string "auditable_name"
    t.datetime "created_at", null: false
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "branch_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_branch_memberships_on_branch_id"
    t.index ["user_id", "branch_id"], name: "index_branch_memberships_on_user_id_and_branch_id", unique: true
    t.index ["user_id"], name: "index_branch_memberships_on_user_id"
  end

  create_table "branches", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "code", limit: 16, null: false
    t.string "name", limit: 120, null: false
    t.integer "status"
    t.integer "{inactive: 0, active: 1}"
    t.string "time_zone", null: false
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "region_code", limit: 10
    t.string "postal_code", limit: 16
    t.string "country_alpha2", limit: 2, null: false
    t.string "phone", limit: 32
    t.string "fax", limit: 32
    t.string "email"
    t.jsonb "operating_hours", default: {}, null: false
    t.decimal "latitude", precision: 9, scale: 6
    t.decimal "longitude", precision: 9, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_branches_on_code", unique: true
    t.index ["country_alpha2", "region_code"], name: "index_branches_on_country_alpha2_and_region_code"
    t.index ["public_id"], name: "index_branches_on_public_id", unique: true
    t.index ["status"], name: "index_branches_on_status"
    t.check_constraint "status = ANY (ARRAY[0, 1])", name: "chk_branches_status"
  end

  create_table "payments_ach_routings", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "routing_number", limit: 9, null: false
    t.string "customer_name", limit: 36, null: false
    t.string "city", limit: 25
    t.string "state_code", limit: 2
    t.string "servicing_frb_number", limit: 9
    t.string "office_code", limit: 1
    t.string "record_type_code", limit: 1
    t.string "institution_status_code", limit: 1
    t.string "data_view_code", limit: 1
    t.string "new_routing_number", limit: 9
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address", limit: 36, comment: "Delivery address"
    t.string "zip_code", limit: 10, comment: "ZIP code"
    t.string "phone_number", limit: 20, comment: "Contact phone, digits only"
    t.text "notes", comment: "Freeform notes"
    t.boolean "us_treasury", default: false, null: false, comment: "ACH number is U.S. Treasury payment"
    t.boolean "us_postal_service", default: false, null: false, comment: "ACH number is U.S. Postal Service money order"
    t.boolean "federal_reserve_bank", default: false, null: false, comment: "Federal Reserve Bank flag"
    t.boolean "on_us", default: false, null: false, comment: "\"On-us\" account"
    t.boolean "special_handling", default: false, null: false, comment: "Docs require special handling"
    t.index ["public_id"], name: "index_payments_ach_routings_on_public_id", unique: true
    t.index ["routing_number"], name: "index_payments_ach_routings_on_routing_number", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_permissions_on_key", unique: true
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_roles_on_key", unique: true
  end

  create_table "system_countries", force: :cascade do |t|
    t.string "alpha2", limit: 2, null: false
    t.string "alpha3", limit: 3, null: false
    t.string "numeric", limit: 3, null: false
    t.text "iso_short_name", null: false
    t.text "iso_long_name"
    t.text "dialing_prefix"
    t.boolean "postal_code_required", default: true, null: false
    t.text "postal_code_regex"
    t.text "address_format"
    t.string "currency_primary_code", limit: 3
    t.jsonb "metadata", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alpha2"], name: "index_system_countries_on_alpha2", unique: true
    t.index ["alpha3"], name: "index_system_countries_on_alpha3", unique: true
    t.index ["currency_primary_code"], name: "index_system_countries_on_currency_primary_code"
    t.index ["numeric"], name: "index_system_countries_on_numeric", unique: true
  end

  create_table "system_country_currencies", force: :cascade do |t|
    t.string "country_alpha2", limit: 2, null: false
    t.string "currency_code", limit: 3, null: false
    t.boolean "is_primary", default: false, null: false
    t.boolean "legal_tender", default: true, null: false
    t.date "valid_from"
    t.date "valid_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_alpha2", "currency_code"], name: "idx_scc_on_country_currency", unique: true
    t.check_constraint "valid_to IS NULL OR valid_from IS NULL OR valid_from <= valid_to", name: "chk_scc_valid_window"
  end

  create_table "system_currencies", force: :cascade do |t|
    t.string "code", limit: 3, null: false
    t.string "numeric", limit: 3, null: false
    t.string "name", null: false
    t.string "full_name"
    t.integer "minor_units", default: 2, null: false
    t.string "symbol"
    t.integer "unicode_codepoint"
    t.boolean "active", default: true, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_system_currencies_on_code", unique: true
    t.index ["numeric"], name: "index_system_currencies_on_numeric", unique: true
    t.check_constraint "minor_units = ANY (ARRAY[0, 1, 2, 3])", name: "chk_currency_minor_units"
  end

  create_table "system_naics_codes", force: :cascade do |t|
    t.string "code", null: false
    t.string "title", null: false
    t.text "description"
    t.string "parent_code"
    t.integer "level", null: false
    t.string "version", default: "2022", null: false
    t.string "sector", limit: 2
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level"], name: "index_system_naics_codes_on_level"
    t.index ["parent_code"], name: "index_system_naics_codes_on_parent_code"
    t.index ["version", "code"], name: "index_system_naics_codes_on_version_and_code", unique: true
  end

  create_table "system_reference_lists", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "tags", default: [], null: false, array: true
    t.index ["key"], name: "index_system_reference_lists_on_key", unique: true
  end

  create_table "system_reference_values", force: :cascade do |t|
    t.bigint "reference_list_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.string "short_name"
    t.text "description"
    t.integer "sort_index", default: 50, null: false
    t.boolean "active", default: true, null: false
    t.string "external_code"
    t.jsonb "metadata", default: {}, null: false
    t.date "valid_from"
    t.date "valid_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference_list_id", "code"], name: "idx_srv_on_list_code", unique: true
    t.index ["reference_list_id"], name: "index_system_reference_values_on_reference_list_id"
  end

  create_table "system_regions", force: :cascade do |t|
    t.string "country_alpha2", limit: 2, null: false
    t.string "region_code", limit: 10, null: false
    t.string "name", null: false
    t.string "kind", null: false
    t.string "iso_code", null: false
    t.boolean "active", default: true, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_alpha2", "region_code"], name: "index_system_regions_on_country_alpha2_and_region_code", unique: true
    t.index ["iso_code"], name: "index_system_regions_on_iso_code", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name", limit: 100, default: "", null: false
    t.string "last_name", limit: 100, default: "", null: false
    t.string "display_name", limit: 150
    t.string "locale", limit: 10
    t.string "phone_e164", limit: 20
    t.string "time_zone", limit: 50, default: "UTC", null: false
    t.string "status", limit: 20, default: "active", null: false
    t.boolean "mfa_enabled", default: false, null: false
    t.datetime "terms_accepted_at"
    t.jsonb "preferences", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_name"], name: "index_users_on_display_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["locale"], name: "index_users_on_locale"
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "branch_memberships", "branches"
  add_foreign_key "branch_memberships", "users"
  add_foreign_key "branches", "system_countries", column: "country_alpha2", primary_key: "alpha2"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "system_country_currencies", "system_countries", column: "country_alpha2", primary_key: "alpha2"
  add_foreign_key "system_country_currencies", "system_currencies", column: "currency_code", primary_key: "code"
  add_foreign_key "system_reference_values", "system_reference_lists", column: "reference_list_id"
  add_foreign_key "system_regions", "system_countries", column: "country_alpha2", primary_key: "alpha2"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
