# db/migrate/20251017023119_add_fks_to_system_reference_values.rb
class AddFksToSystemReferenceValues < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_foreign_key :system_reference_values, :system_reference_lists,
      column: :system_reference_list_id, validate: false, name: "fk_srv_to_lists"

    add_foreign_key :system_reference_values, :system_reference_values,
      column: :parent_id, validate: false, name: "fk_srv_to_parent"
  end

  def down
    remove_foreign_key :system_reference_values, name: "fk_srv_to_parent"
    remove_foreign_key :system_reference_values, name: "fk_srv_to_lists"
  end
end
