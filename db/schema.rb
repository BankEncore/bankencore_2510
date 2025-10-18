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

ActiveRecord::Schema[8.0].define(version: 2025_10_18_185603) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "payments_ach_routings", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "routing_number", limit: 9, null: false, comment: "Institution’s ABA routing number"
    t.string "office_code", limit: 1, default: "0", null: false, comment: "'O' main office, 'B' branch"
    t.string "servicing_frb_number", limit: 9, comment: "Servicing Federal Reserve Bank routing number"
    t.string "record_type_code", limit: 1, default: "0", null: false, comment: "0=Fed, 1=send to customer, 2=send using new routing number"
    t.date "change_date", comment: "Last update date (MMDDYY source)"
    t.string "new_routing_number", limit: 9, default: "000000000", comment: "Updated routing number (e.g., merger)"
    t.string "customer_name", limit: 36, null: false, comment: "Abbreviated institution name"
    t.string "address", limit: 36, comment: "Delivery address"
    t.string "city", limit: 20, comment: "City name"
    t.string "state_code", limit: 2, comment: "Two-letter state abbreviation"
    t.bigint "system_region_id", comment: "Optional FK to SystemRegion (US)"
    t.string "zip_code", limit: 10, comment: "ZIP code"
    t.string "phone_number", limit: 10, comment: "Contact phone, digits only"
    t.string "institution_status_code", limit: 1, default: "1", comment: "1 = Receives gov/commercial ACH data"
    t.string "data_view_code", limit: 1, default: "1", comment: "1 = Current view"
    t.boolean "us_treasury", default: false, null: false, comment: "ACH number is U.S. Treasury payment"
    t.boolean "us_postal_service", default: false, null: false, comment: "ACH number is U.S. Postal Service money order"
    t.boolean "federal_reserve_bank", default: false, null: false, comment: "ACH number is a Federal Reserve Bank"
    t.boolean "on_us", default: false, null: false, comment: "\"On-us\" account"
    t.boolean "local", default: false, null: false, comment: "Considered a local check"
    t.boolean "special_handling", default: false, null: false, comment: "Docs require special handling"
    t.text "notes", comment: "Internal notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_name"], name: "index_payments_ach_routings_on_customer_name"
    t.index ["public_id"], name: "index_payments_ach_routings_on_public_id", unique: true
    t.index ["routing_number"], name: "index_payments_ach_routings_on_routing_number", unique: true
    t.index ["state_code"], name: "index_payments_ach_routings_on_state_code"
    t.index ["system_region_id"], name: "index_payments_ach_routings_on_system_region_id"
    t.check_constraint "data_view_code IS NULL OR data_view_code::text = '1'::text", name: "chk_par_data_view_code"
    t.check_constraint "new_routing_number IS NULL OR new_routing_number::text ~ '^[0-9]{9}$'::text", name: "chk_par_new_rtn_digits"
    t.check_constraint "office_code::text = ANY (ARRAY['O'::character varying::text, 'B'::character varying::text])", name: "chk_par_office_code"
    t.check_constraint "phone_number IS NULL OR phone_number::text ~ '^[0-9]{10}$'::text", name: "chk_par_phone_digits"
    t.check_constraint "record_type_code::text = ANY (ARRAY['0'::character varying::text, '1'::character varying::text, '2'::character varying::text])", name: "chk_par_record_type_code"
    t.check_constraint "routing_number::text ~ '^[0-9]{9}$'::text", name: "chk_par_routing_number_digits"
    t.check_constraint "servicing_frb_number IS NULL OR servicing_frb_number::text ~ '^[0-9]{9}$'::text", name: "chk_par_frb_digits"
    t.check_constraint "state_code IS NULL OR state_code::text ~ '^[A-Z]{2}$'::text", name: "chk_par_state_code"
  end

  create_table "system_countries", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "iso2", limit: 2, null: false
    t.string "iso3", limit: 3, null: false
    t.string "numeric", limit: 3
    t.string "name", null: false
    t.string "official_name"
    t.string "calling_code"
    t.string "currency_code", limit: 3
    t.string "region"
    t.string "subregion"
    t.string "tlds", default: [], array: true
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iso2"], name: "index_system_countries_on_iso2", unique: true
    t.index ["iso3"], name: "index_system_countries_on_iso3", unique: true
    t.index ["numeric"], name: "index_system_countries_on_numeric"
    t.index ["public_id"], name: "index_system_countries_on_public_id", unique: true
  end

  create_table "system_country_currencies", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "country_id", null: false
    t.bigint "currency_id", null: false
    t.boolean "default_for_country", default: true, null: false
    t.date "valid_from"
    t.date "valid_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "currency_id"], name: "idx_scc_on_country_currency", unique: true
    t.index ["country_id"], name: "idx_scc_default_per_country", where: "default_for_country"
    t.index ["public_id"], name: "index_system_country_currencies_on_public_id", unique: true
    t.check_constraint "valid_to IS NULL OR valid_from IS NULL OR valid_from <= valid_to", name: "chk_scc_valid_window"
  end

  create_table "system_currencies", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "code", limit: 3, null: false
    t.string "numeric", limit: 3
    t.string "name", null: false
    t.integer "minor_units", default: 2, null: false
    t.string "symbol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_system_currencies_on_code", unique: true
    t.index ["public_id"], name: "index_system_currencies_on_public_id", unique: true
  end

  create_table "system_naics_codes", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.integer "year", default: 2022, null: false
    t.string "code", null: false
    t.string "title", null: false
    t.string "sector"
    t.string "parent_code"
    t.integer "level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.index ["public_id"], name: "index_system_naics_codes_on_public_id", unique: true
    t.index ["year", "code"], name: "index_system_naics_codes_on_year_and_code", unique: true
    t.index ["year", "parent_code"], name: "index_system_naics_codes_on_year_and_parent_code"
  end

  create_table "system_reference_lists", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "key", null: false
    t.string "name", null: false
    t.string "description"
    t.string "schema_version"
    t.string "visibility", default: "public", null: false
    t.string "tags", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_system_reference_lists_on_key", unique: true
    t.index ["public_id"], name: "index_system_reference_lists_on_public_id", unique: true
  end

  create_table "system_reference_values", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "parent_id"
    t.string "key", null: false
    t.string "code"
    t.string "label", null: false
    t.string "short_label"
    t.text "description"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.date "effective_from"
    t.date "effective_to"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "reference_list_id", null: false
    t.bigint "system_reference_list_id"
    t.index ["metadata"], name: "index_system_reference_values_on_metadata", using: :gin
    t.index ["parent_id"], name: "index_system_reference_values_on_parent_id"
    t.index ["public_id"], name: "index_system_reference_values_on_public_id", unique: true
    t.index ["reference_list_id"], name: "index_system_reference_values_on_reference_list_id"
    t.index ["system_reference_list_id"], name: "index_system_reference_values_on_system_reference_list_id"
  end

  create_table "system_regions", force: :cascade do |t|
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "system_country_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.string "type_name", default: "state", null: false
    t.string "iso_3166_2"
    t.string "fips_code"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_system_regions_on_public_id", unique: true
    t.index ["system_country_id", "code"], name: "index_system_regions_on_system_country_id_and_code", unique: true
    t.index ["system_country_id"], name: "index_system_regions_on_system_country_id"
  end

  add_foreign_key "payments_ach_routings", "system_regions"
  add_foreign_key "system_country_currencies", "system_countries", column: "country_id"
  add_foreign_key "system_country_currencies", "system_currencies", column: "currency_id"
  add_foreign_key "system_reference_values", "system_reference_lists"
  add_foreign_key "system_reference_values", "system_reference_lists", column: "reference_list_id"
  add_foreign_key "system_reference_values", "system_reference_values", column: "parent_id", name: "fk_srv_to_parent"
  add_foreign_key "system_regions", "system_countries"
end
