# db/migrate/20251027143412_validate_fk_parties_organizations.rb
class ValidateFkPartiesOrganizations < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_organizations, :system_countries,  column: :residence_country
    validate_foreign_key :parties_organizations, :system_naics_codes, column: :system_naics_code_id
  end
end
