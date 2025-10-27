# db/migrate/20251027143452_create_parties_tax_ids.rb
class CreatePartiesTaxIds < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_tax_ids do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string  :tax_id_type_code, null: false
      t.string  :value, null: false
      t.string  :country
      t.date    :b_notice1_sent_on
      t.date    :b_notice2_sent_on
      t.date    :w8_signed_on
      t.timestamps
    end

    add_index :parties_tax_ids, :tax_id_type_code
    add_index :parties_tax_ids, [ :party_id, :tax_id_type_code, :value ], unique: true, name: "idx_unique_taxid_per_party_type"

    # defer FK validation per Strong Migrations
    add_foreign_key :parties_tax_ids, :system_countries,
      column: :country, primary_key: :alpha2, validate: false
  end
end
