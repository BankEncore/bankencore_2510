# db/migrate/20251021023107_ensure_unique_idx_on_srv_list_code.rb
class EnsureUniqueIdxOnSrvListCode < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    if column_exists?(:system_reference_values, :reference_list_id) &&
       !index_exists?(:system_reference_values, [ :reference_list_id, :code ], name: :idx_srv_on_list_code)
      add_index :system_reference_values, [ :reference_list_id, :code ],
                unique: true, name: :idx_srv_on_list_code, algorithm: :concurrently
    end

    if column_exists?(:system_reference_values, :system_reference_list_id) &&
       !index_exists?(:system_reference_values, [ :system_reference_list_id, :code ], name: :idx_srv_on_syslist_code)
      add_index :system_reference_values, [ :system_reference_list_id, :code ],
                unique: true, name: :idx_srv_on_syslist_code, algorithm: :concurrently
    end
  end

  def down
    remove_index :system_reference_values, name: :idx_srv_on_list_code   if index_exists?(:system_reference_values, name: :idx_srv_on_list_code)
    remove_index :system_reference_values, name: :idx_srv_on_syslist_code if index_exists?(:system_reference_values, name: :idx_srv_on_syslist_code)
  end
end
