class ValidateSystemCountryCurrenciesFKs < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key :system_country_currencies, :system_countries
    validate_foreign_key :system_country_currencies, :system_currencies
  end
end
