# db/migrate/20251017_add_reference_list_id_to_system_reference_values.rb
class AddReferenceListIdToSystemReferenceValues < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :system_reference_values, :reference_list_id, :bigint

    # backfill 1:1 copy if old column exists
    execute <<~SQL
      UPDATE system_reference_values
      SET reference_list_id = system_reference_list_id
      WHERE reference_list_id IS NULL
        AND system_reference_list_id IS NOT NULL
    SQL

    # index + fk
    add_index :system_reference_values, :reference_list_id, algorithm: :concurrently
    add_foreign_key :system_reference_values, :system_reference_lists, column: :reference_list_id
  end
end
