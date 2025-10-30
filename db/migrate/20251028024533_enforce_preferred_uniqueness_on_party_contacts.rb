# db/migrate/20251028000000_enforce_preferred_uniqueness_on_party_contacts.rb
class EnforcePreferredUniquenessOnPartyContacts < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :parties_names,            [ :party_id ],
      unique: true, where: "preferred",
      name: "uq_names_one_preferred", algorithm: :concurrently

    add_index :parties_phones,           [ :party_id ],
      unique: true, where: "preferred",
      name: "uq_phones_one_preferred", algorithm: :concurrently

    add_index :parties_postal_addresses, [ :party_id ],
      unique: true, where: "preferred",
      name: "uq_postal_addresses_one_preferred", algorithm: :concurrently

    add_index :parties_email_addresses,  [ :party_id ],
      unique: true, where: "preferred",
      name: "uq_email_addresses_one_preferred", algorithm: :concurrently

    add_index :parties_web_addresses,    [ :party_id ],
      unique: true, where: "preferred",
      name: "uq_web_addresses_one_preferred", algorithm: :concurrently
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS uq_names_one_preferred"
    execute "DROP INDEX CONCURRENTLY IF EXISTS uq_phones_one_preferred"
    execute "DROP INDEX CONCURRENTLY IF EXISTS uq_postal_addresses_one_preferred"
    execute "DROP INDEX CONCURRENTLY IF EXISTS uq_email_addresses_one_preferred"
    execute "DROP INDEX CONCURRENTLY IF EXISTS uq_web_addresses_one_preferred"
  end
end
