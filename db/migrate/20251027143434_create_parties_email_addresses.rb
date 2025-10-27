# db/migrate/20251027000700_create_parties_email_addresses.rb
class CreatePartiesEmailAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_email_addresses do |t|
      t.bigint   :party_id, null: false
      t.string   :email_type_code, null: false
      t.string   :email
      t.timestamp :verified_at
      t.boolean  :preferred, null: false, default: false
      t.date     :valid_from
      t.date     :valid_to
      t.timestamps
    end

    add_index :parties_email_addresses, :party_id
  end
end
