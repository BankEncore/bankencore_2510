# db/migrate/20251017023219_validate_fks_to_system_reference_values.rb
class ValidateFksToSystemReferenceValues < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :system_reference_values, :system_reference_lists, name: "fk_srv_to_lists"
    validate_foreign_key :system_reference_values, :system_reference_values, name: "fk_srv_to_parent"
  end
end
