# db/migrate/20251027000702_validate_fk_parties_email_addresses.rb
class ValidateFkPartiesEmailAddresses < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_email_addresses, :parties_parties, column: :party_id
  end
end
