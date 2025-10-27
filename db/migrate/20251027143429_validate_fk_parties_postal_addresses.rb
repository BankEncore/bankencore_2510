# db/migrate/20251027143429_validate_fk_parties_postal_addresses.rb
class ValidateFkPartiesPostalAddresses < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_postal_addresses, :system_regions,   column: :system_region_id
    validate_foreign_key :parties_postal_addresses, :system_countries, column: :country
  end
end
