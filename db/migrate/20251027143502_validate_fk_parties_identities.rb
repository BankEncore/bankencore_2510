# db/migrate/20251027143502_validate_fk_parties_identities.rb
class ValidateFkPartiesIdentities < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_identities, :system_countries, column: :issuing_country
    validate_foreign_key :parties_identities, :system_regions,   column: :system_region_id
  end
end
