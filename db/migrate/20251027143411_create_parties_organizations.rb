# db/migrate/20251027143411_create_parties_organizations.rb
class CreatePartiesOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_organizations, id: false do |t|
      t.references :party, null: false, index: { unique: true }, foreign_key: { to_table: :parties_parties }
      t.date    :established_on
      t.string  :residence_country
      t.string  :organization_type_code
      t.bigint  :system_naics_code_id
      t.string  :tax_exempt_code
      t.timestamps
    end

    add_index :parties_organizations, :organization_type_code
    add_index :parties_organizations, :tax_exempt_code
    add_index :parties_organizations, :system_naics_code_id

    add_foreign_key :parties_organizations, :system_countries,
      column: :residence_country, primary_key: :alpha2, validate: false
    add_foreign_key :parties_organizations, :system_naics_codes,
      column: :system_naics_code_id, validate: false
  end
end
