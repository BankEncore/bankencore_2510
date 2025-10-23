# db/migrate/20251020170400_enforce_public_id_constraints.rb
class EnforcePublicIdConstraints < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :system_reference_lists,    :public_id, unique: true, algorithm: :concurrently, name: "idx_srl_public_id_unique"
    add_index :system_reference_values,   :public_id, unique: true, algorithm: :concurrently, name: "idx_srv_public_id_unique"
    add_index :system_naics_codes,        :public_id, unique: true, algorithm: :concurrently, name: "idx_snc_public_id_unique"
    add_index :system_country_currencies, :public_id, unique: true, algorithm: :concurrently, name: "idx_scc_public_id_unique"

    # Strong Migrations-safe NOT NULL: optional `safety_assured` if the tables are small.
    safety_assured do
      change_column_null :system_reference_lists,    :public_id, false
      change_column_null :system_reference_values,   :public_id, false
      change_column_null :system_naics_codes,        :public_id, false
      change_column_null :system_country_currencies, :public_id, false
    end
  end

  def down
    remove_index :system_reference_lists,    name: "idx_srl_public_id_unique"
    remove_index :system_reference_values,   name: "idx_srv_public_id_unique"
    remove_index :system_naics_codes,        name: "idx_snc_public_id_unique"
    remove_index :system_country_currencies, name: "idx_scc_public_id_unique"
    change_column_null :system_reference_lists,    :public_id, true
    change_column_null :system_reference_values,   :public_id, true
    change_column_null :system_naics_codes,        :public_id, true
    change_column_null :system_country_currencies, :public_id, true
  end
end
