# db/migrate/20251027143453_validate_fk_parties_tax_ids_country.rb
class ValidateFkPartiesTaxIdsCountry < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_tax_ids, :system_countries, column: :country
  end
end
