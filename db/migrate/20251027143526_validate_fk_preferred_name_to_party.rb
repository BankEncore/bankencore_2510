# db/migrate/20251027143526_validate_fk_preferred_name_to_party.rb
class ValidateFkPreferredNameToParty < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_parties, :parties_names, column: :preferred_party_name_id
  end
end
