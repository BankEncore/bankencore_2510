# db/migrate/20251020164403_install_audited.rb
class InstallAudited < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    return if table_exists?(:audits)

    create_table :audits, id: :bigserial do |t|
      t.string  :auditable_type, null: false
      t.bigint  :auditable_id,   null: false
      t.string  :associated_type
      t.bigint  :associated_id
      t.string  :user_type
      t.bigint  :user_id
      t.string  :username
      t.string  :action,         null: false
      t.jsonb   :audited_changes
      t.integer :version,        null: false, default: 0
      t.string  :comment
      t.string  :remote_address
      t.string  :request_uuid
      t.datetime :created_at,    null: false
    end

    add_index :audits, [ :auditable_type, :auditable_id ], algorithm: :concurrently
    add_index :audits, [ :associated_type, :associated_id ], algorithm: :concurrently
    add_index :audits, [ :user_id, :user_type ],             algorithm: :concurrently
    add_index :audits, :request_uuid,                       algorithm: :concurrently
    add_index :audits, :created_at,                         algorithm: :concurrently
  end

  def down
    drop_table :audits if table_exists?(:audits)
  end
end
