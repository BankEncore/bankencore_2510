# db/migrate/20251027143525_add_fk_preferred_name_to_party.rb
class AddFkPreferredNameToParty < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :parties_parties, :preferred_party_name_id, algorithm: :concurrently
    add_foreign_key :parties_parties, :parties_names,
      column: :preferred_party_name_id, validate: false
  end

  def down
    remove_foreign_key :parties_parties, column: :preferred_party_name_id
    remove_index :parties_parties, :preferred_party_name_id
  end
end
