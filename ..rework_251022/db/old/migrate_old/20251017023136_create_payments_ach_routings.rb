# db/migrate/20251016150000_create_payments_ach_routings.rb
class CreatePaymentsAchRoutings < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :payments_ach_routings do |t|
      t.uuid   :public_id,              null: false, default: "gen_random_uuid()"

      t.string :routing_number,         null: false, limit: 9,  comment: "Institution’s ABA routing number"
      t.string :office_code,            null: false, limit: 1,  comment: "'O' main office, 'B' branch"
      t.string :servicing_frb_number,                 limit: 9,  comment: "Servicing Federal Reserve Bank routing number"
      t.string :record_type_code,       null: false, limit: 1,  comment: "0=Fed, 1=send to customer, 2=send using new routing number"
      t.date   :change_date,                                        comment: "Last update date (MMDDYY source)"
      t.string :new_routing_number,                   limit: 9,  comment: "Updated routing number (e.g., merger)"
      t.string :customer_name,          null: false, limit: 36, comment: "Abbreviated institution name"
      t.string :address,                              limit: 36, comment: "Delivery address"
      t.string :city,                                 limit: 20, comment: "City name"

      # Region linkage
      t.string :state_code,            null: false, limit: 2,  comment: "Two-letter state abbreviation"
      t.references :system_region, foreign_key: true, null: true, comment: "Optional FK to SystemRegion (US)"

      t.string :zip_code,                            limit: 10, comment: "ZIP code"
      t.string :phone_number,                        limit: 10, comment: "Contact phone, digits only"
      t.string :institution_status_code,             limit: 1,  comment: "1 = Receives gov/commercial ACH data"
      t.string :data_view_code,                      limit: 1,  comment: "1 = Current view"

      t.boolean :us_treasury,          null: false, default: false, comment: "ACH number is U.S. Treasury payment"
      t.boolean :us_postal_service,    null: false, default: false, comment: "ACH number is U.S. Postal Service money order"
      t.boolean :federal_reserve_bank, null: false, default: false, comment: "ACH number is a Federal Reserve Bank"
      t.boolean :on_us,                null: false, default: false, comment: '"On-us" account'
      t.boolean :local,                null: false, default: false, comment: "Considered a local check"
      t.boolean :special_handling,     null: false, default: false, comment: "Docs require special handling"

      t.text :notes, comment: "Internal notes"

      t.timestamps
    end

    add_index :payments_ach_routings, :public_id, unique: true
    add_index :payments_ach_routings, :routing_number, unique: true
    add_index :payments_ach_routings, :customer_name
    add_index :payments_ach_routings, :state_code

    # Data quality checks
    add_check_constraint :payments_ach_routings, "routing_number ~ '^[0-9]{9}$'", name: "chk_par_routing_number_digits"
    add_check_constraint :payments_ach_routings, "servicing_frb_number IS NULL OR servicing_frb_number ~ '^[0-9]{9}$'", name: "chk_par_frb_digits"
    add_check_constraint :payments_ach_routings, "new_routing_number IS NULL OR new_routing_number ~ '^[0-9]{9}$'", name: "chk_par_new_rtn_digits"
    add_check_constraint :payments_ach_routings, "office_code IN ('O','B')", name: "chk_par_office_code"
    add_check_constraint :payments_ach_routings, "record_type_code IN ('0','1','2')", name: "chk_par_record_type_code"
    add_check_constraint :payments_ach_routings, "data_view_code IS NULL OR data_view_code IN ('1')", name: "chk_par_data_view_code"
    add_check_constraint :payments_ach_routings, "state_code ~ '^[A-Z]{2}$'", name: "chk_par_state_code"
    add_check_constraint :payments_ach_routings, "phone_number IS NULL OR phone_number ~ '^[0-9]{10}$'", name: "chk_par_phone_digits"
  end
end
