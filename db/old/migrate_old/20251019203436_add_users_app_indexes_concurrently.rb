# db/migrate/XXXXXXXXXXXXXX_add_users_app_indexes_concurrently.rb
class AddUsersAppIndexesConcurrently < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :users, :role,           algorithm: :concurrently
    add_index :users, :status,         algorithm: :concurrently
    add_index :users, :last_active_at, algorithm: :concurrently
  end
end
