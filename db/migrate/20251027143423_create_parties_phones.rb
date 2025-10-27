# 20251027000500_create_parties_phones.rb
class CreatePartiesPhones < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_phones do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string  :phone_type_code, null: false
      t.string  :e164
      t.timestamp :verified_at
      t.boolean :preferred, null: false, default: false
      t.date    :valid_from
      t.date    :valid_to
      t.string  :invalid_reason
      t.timestamps
    end

    add_index :parties_phones, :phone_type_code
    add_index :parties_phones, :e164
    safety_assured do
    execute <<~SQL
      CREATE UNIQUE INDEX idx_unique_preferred_phone_per_party
      ON parties_phones (party_id)
      WHERE preferred = TRUE;
    SQL
    end
  end
end
