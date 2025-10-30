# db/migrate/20251027201000_add_party_id_if_missing.rb
class AddPartyIdToPartiesChildren < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  TARGETS = %i[
    names phones email_addresses postal_addresses web_addresses
    tax_ids identities disclosures secret_data consents communication_preferences
  ].freeze

  def up
    TARGETS.each do |t|
      tbl = :"parties_#{t}"
      next unless table_exists?(tbl)

      unless column_exists?(tbl, :party_id)
        add_column tbl, :party_id, :bigint
      end

      unless index_exists?(tbl, :party_id)
        add_index  tbl, :party_id, algorithm: :concurrently
      end

      unless foreign_key_exists?(tbl, :parties_parties, column: :party_id)
        add_foreign_key tbl, :parties_parties, column: :party_id, validate: false
      end
    end
  end

  def down
    TARGETS.each do |t|
      tbl = :"parties_#{t}"
      next unless table_exists?(tbl)

      if foreign_key_exists?(tbl, :parties_parties, column: :party_id)
        remove_foreign_key tbl, column: :party_id
      end
      if index_exists?(tbl, :party_id)
        remove_index tbl, :party_id, algorithm: :concurrently
      end
      remove_column tbl, :party_id if column_exists?(tbl, :party_id)
    end
  end
end
