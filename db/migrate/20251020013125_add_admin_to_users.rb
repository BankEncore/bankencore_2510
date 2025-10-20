# db/migrate/XXXXXXXXXXXXXX_add_admin_to_users.rb
class AddAdminToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :users, :admin, algorithm: :concurrently
  end
end