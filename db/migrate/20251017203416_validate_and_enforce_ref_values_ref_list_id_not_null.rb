# db/migrate/20251017_validate_and_enforce_ref_values_ref_list_id_not_null.rb
class ValidateAndEnforceRefValuesRefListIdNotNull < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # backfill any remaining NULLs from the old column
      execute <<~SQL
        UPDATE system_reference_values
        SET reference_list_id = system_reference_list_id
        WHERE reference_list_id IS NULL AND system_reference_list_id IS NOT NULL
      SQL

      # fail fast if any NULLs remain
      nulls = select_value("SELECT COUNT(*) FROM system_reference_values WHERE reference_list_id IS NULL").to_i
      raise "Abort: #{nulls} rows still NULL in reference_list_id" if nulls.positive?

      validate_check_constraint :system_reference_values, name: "system_reference_values_reference_list_id_null"
      change_column_null :system_reference_values, :reference_list_id, false
      remove_check_constraint :system_reference_values, name: "system_reference_values_reference_list_id_null"
    end
  end

  def down
    safety_assured do
      add_check_constraint :system_reference_values, "reference_list_id IS NOT NULL",
        name: "system_reference_values_reference_list_id_null", validate: true
      change_column_null :system_reference_values, :reference_list_id, true
    end
  end
end
