class AddAppFieldsToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  def change
    add_column :users, :name,              :string,  limit: 100
    add_column :users, :time_zone,         :string,  limit: 50,  default: "UTC"
    add_column :users, :role,              :string,  limit: 30,  null: false, default: "user"
    add_column :users, :status,            :string,  limit: 20,  null: false, default: "active" # active/suspended/invited
    add_column :users, :last_active_at,    :datetime
    add_column :users, :mfa_enabled,       :boolean, null: false, default: false
    add_column :users, :terms_accepted_at, :datetime
  end
end
