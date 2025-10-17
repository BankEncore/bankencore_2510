# db/migrate/20251017_add_check_ref_values_ref_list_id_not_null.rb
class AddCheckRefValuesRefListIdNotNull < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :system_reference_values,
      "reference_list_id IS NOT NULL",
      name: "system_reference_values_reference_list_id_null",
      validate: false
  end
end
