# db/migrate/20251018152632_fix_reference_values_fk.rb
class FixReferenceValuesFk < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_column :system_reference_values, :system_reference_list_id, :bigint \
      unless column_exists?(:system_reference_values, :system_reference_list_id)

    if column_exists?(:system_reference_values, :reference_list_id)
      say_with_time "Backfilling system_reference_list_id from reference_list_id" do
        # batch to keep locks small
        System::ReferenceValue.where(system_reference_list_id: nil)
                              .in_batches(of: 5_000) do |rel|
          rel.update_all("system_reference_list_id = reference_list_id")
        end
      end
    end

    add_index :system_reference_values, :system_reference_list_id, algorithm: :concurrently \
      unless index_exists?(:system_reference_values, :system_reference_list_id)

    if table_exists?(:system_reference_lists)
      add_foreign_key :system_reference_values, :system_reference_lists,
                      column: :system_reference_list_id, validate: false
      validate_foreign_key :system_reference_values, :system_reference_lists
    end
  end

  def down
    remove_foreign_key :system_reference_values, column: :system_reference_list_id rescue nil
    remove_index :system_reference_values, :system_reference_list_id rescue nil
    remove_column :system_reference_values, :system_reference_list_id if column_exists?(:system_reference_values, :system_reference_list_id)
  end
end
