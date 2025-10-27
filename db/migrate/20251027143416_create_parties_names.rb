# 20251027000400_create_parties_names.rb
class CreatePartiesNames < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_names do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string  :name_type_code, null: false
      t.string  :full_name
      t.string  :family_name
      t.string  :given_name
      t.string  :middle_name
      t.string  :prefix_code
      t.string  :suffix_code
      t.boolean :preferred, null: false, default: false
      t.date    :valid_from
      t.date    :valid_to
      t.timestamps
    end

    add_index :parties_names, :name_type_code
    add_index :parties_names, :preferred
    safety_assured do
    execute <<~SQL
      CREATE UNIQUE INDEX idx_unique_preferred_name_per_party
      ON parties_names (party_id)
      WHERE preferred = TRUE;
    SQL
    end
  end
end
