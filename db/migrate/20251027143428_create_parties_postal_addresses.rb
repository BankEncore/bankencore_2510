# db/migrate/20251027143428_create_parties_postal_addresses.rb
class CreatePartiesPostalAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_postal_addresses do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string  :address_use_code
      t.string  :address_type_code
      t.string  :line1
      t.string  :line2
      t.string  :line3
      t.string  :line4
      t.string  :city
      t.bigint  :system_region_id
      t.string  :postal_code
      t.string  :country
      t.boolean :preferred, null: false, default: false
      t.date    :valid_from
      t.date    :valid_to
      t.timestamps
    end

    add_index :parties_postal_addresses, :address_use_code
    add_index :parties_postal_addresses, :address_type_code
    add_index :parties_postal_addresses, :country
    add_index :parties_postal_addresses, :system_region_id

    # defer FK validation
    add_foreign_key :parties_postal_addresses, :system_regions,
      column: :system_region_id, validate: false
    add_foreign_key :parties_postal_addresses, :system_countries,
      column: :country, primary_key: :alpha2, validate: false

    safety_assured do
    execute <<~SQL
      CREATE UNIQUE INDEX idx_unique_preferred_address_per_party
      ON parties_postal_addresses (party_id)
      WHERE preferred = TRUE;
    SQL
    end
  end
end
