# db/migrate/20251027000701_add_indexes_and_fk_to_parties_email_addresses.rb
class AddIndexesAndFkToPartiesEmailAddresses < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :parties_email_addresses, :email_type_code, algorithm: :concurrently
    add_index :parties_email_addresses, :email, algorithm: :concurrently
    add_index :parties_email_addresses,
              [ :party_id, :email_type_code, :email ],
              unique: true,
              name: "idx_unique_party_email_by_type",
              algorithm: :concurrently

    safety_assured do
      execute <<~SQL
        CREATE UNIQUE INDEX CONCURRENTLY idx_unique_preferred_email_per_party
        ON parties_email_addresses (party_id)
        WHERE preferred = TRUE;
      SQL
    end

    add_foreign_key :parties_email_addresses, :parties_parties,
      column: :party_id, validate: false
  end

  def down
    remove_foreign_key :parties_email_addresses, column: :party_id
    safety_assured do
      execute "DROP INDEX CONCURRENTLY IF EXISTS idx_unique_preferred_email_per_party;"
    end
    remove_index :parties_email_addresses, name: "idx_unique_party_email_by_type"
    remove_index :parties_email_addresses, :email
    remove_index :parties_email_addresses, :email_type_code
  end
end
