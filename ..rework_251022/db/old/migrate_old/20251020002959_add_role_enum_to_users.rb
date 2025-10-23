# db/migrate/20251020002959_add_role_enum_to_users.rb
class AddRoleEnumToUsers < ActiveRecord::Migration[8.0]
  class MUser < ActiveRecord::Base; self.table_name = "users"; end

  def up
    # add nullable, no default
    add_column :users, :role_i, :integer

    # backfill
    say_with_time "Backfilling users.role_i from users.role" do
      MUser.where(role: "system_admin").update_all(role_i: 2)
      MUser.where(role: "staff").update_all(role_i: 1)
      MUser.where.not(role: %w[system_admin staff]).update_all(role_i: 0)
    end

    # set default only (safe)
    change_column_default :users, :role_i, from: nil, to: 0
  end

  def down
    change_column_default :users, :role_i, from: 0, to: nil
    remove_column :users, :role_i
  end
end
