# db/migrate/20251020003944_validate_users_role_i_not_null.rb
class ValidateUsersRoleINotNull < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_check_constraint :users, "role_i IS NOT NULL",
                         name: "users_role_i_null", validate: false
    validate_check_constraint :users, name: "users_role_i_null"
    change_column_null :users, :role_i, false
    remove_check_constraint :users, name: "users_role_i_null"
  end

  def down
    add_check_constraint :users, "role_i IS NOT NULL",
                         name: "users_role_i_null", validate: false
    change_column_null :users, :role_i, true
    remove_check_constraint :users, name: "users_role_i_null"
  end
end
