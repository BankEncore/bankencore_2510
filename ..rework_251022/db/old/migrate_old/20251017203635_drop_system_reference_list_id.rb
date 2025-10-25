# db/migrate/20251017_drop_system_reference_list_id.rb
class DropSystemReferenceListId < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  def change
    safety_assured { remove_column :system_reference_values, :system_reference_list_id, :bigint }
  end
end
