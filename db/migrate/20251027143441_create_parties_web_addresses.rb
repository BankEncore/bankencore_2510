# 20251027000800_create_parties_web_addresses.rb
class CreatePartiesWebAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_web_addresses do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string  :url
      t.boolean :preferred, null: false, default: false
      t.date    :valid_from
      t.date    :valid_to
      t.timestamps
    end

    add_index :parties_web_addresses, :url
    safety_assured do
    execute <<~SQL
      CREATE UNIQUE INDEX idx_unique_preferred_web_per_party
      ON parties_web_addresses (party_id)
      WHERE preferred = TRUE;
    SQL
    end
  end
end
