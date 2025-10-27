# db/migrate/20251027143501_create_parties_identities.rb
class CreatePartiesIdentities < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_identities do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string  :identity_type_code, null: false
      t.string  :number
      t.string  :issuing_country
      t.bigint  :system_region_id
      t.string  :issuer_name
      t.date    :issued_on
      t.date    :expires_on
      t.jsonb   :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :parties_identities, :identity_type_code
    add_index :parties_identities, :expires_on
    add_index :parties_identities, :metadata, using: :gin

    add_foreign_key :parties_identities, :system_countries,
      column: :issuing_country, primary_key: :alpha2, validate: false
    add_foreign_key :parties_identities, :system_regions,
      column: :system_region_id, validate: false
  end
end
