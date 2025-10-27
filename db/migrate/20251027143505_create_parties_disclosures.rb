# 20251027001100_create_parties_disclosures.rb
class CreatePartiesDisclosures < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_disclosures do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string    :disclosure_type_code, null: false
      t.string    :ack_type_code
      t.timestamp :acknowledged_at
      t.timestamps
    end

    add_index :parties_disclosures, :disclosure_type_code
    add_index :parties_disclosures, :ack_type_code
  end
end
