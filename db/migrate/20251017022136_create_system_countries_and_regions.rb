class CreateSystemCountriesAndRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :system_countries do |t|
      t.uuid   :public_id,   default: "gen_random_uuid()", null: false
      t.string :iso2,        null: false, limit: 2
      t.string :iso3,        null: false, limit: 3
      t.string :numeric,                 limit: 3
      t.string :name,        null: false
      t.string :official_name
      t.string :calling_code            # e.g., "+1"
      t.string :currency_code, limit: 3 # ISO-4217
      t.string :region                   # UN region
      t.string :subregion
      t.string :tlds, array: true, default: []
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :system_countries, :public_id, unique: true
    add_index :system_countries, :iso2,      unique: true
    add_index :system_countries, :iso3,      unique: true
    add_index :system_countries, :numeric

    create_table :system_regions do |t|
      t.uuid :public_id, default: "gen_random_uuid()", null: false
      t.references :system_country, null: false, foreign_key: true
      t.string  :code,       null: false                  # postal/ISO-3166-2 code
      t.string  :name,       null: false
      t.string  :type_name,  null: false, default: "state" # state|province|territory
      t.string  :iso_3166_2                                # e.g., "US-MI"
      t.string  :fips_code
      t.boolean :active,     null: false, default: true
      t.timestamps
    end
    add_index :system_regions, :public_id, unique: true
    add_index :system_regions, [ :system_country_id, :code ], unique: true
  end
end
