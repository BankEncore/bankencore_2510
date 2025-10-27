# db/migrate/20251027143407_validate_fk_parties_individuals_res_country.rb
class ValidateFkPartiesIndividualsResCountry < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_individuals, :system_countries, column: :residence_country
  end
end
