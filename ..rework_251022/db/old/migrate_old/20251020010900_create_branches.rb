# db/migrate/20251019120000_create_branches.rb
class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
      t.uuid   :public_id, null: false, default: -> { "gen_random_uuid()" }
      t.string :code,  null: false, limit: 10
      t.string :name,  null: false, limit: 100
      t.string :status, null: false, default: "active" # active, inactive, closed
      t.timestamps
    end
    add_index :branches, :public_id, unique: true
    add_index :branches, :code, unique: true

    create_table :branch_memberships do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :branch,  null: false, foreign_key: true
      t.timestamps
    end
    add_index :branch_memberships, [ :user_id, :branch_id ], unique: true
  end
end
