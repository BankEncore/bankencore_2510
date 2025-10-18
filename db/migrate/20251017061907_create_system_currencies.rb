# db/migrate/20251017050000_create_system_currencies.rb
class CreateSystemCurrencies < ActiveRecord::Migration[8.0]
  def change
    create_table :system_currencies do |t|
      t.uuid   :public_id,    null: false, default: "gen_random_uuid()"
      t.string :code,         null: false, limit: 3    # ISO-4217 code
      t.string :numeric,                     limit: 3
      t.string :name,         null: false
      t.integer :minor_units,  null: false, default: 2  # exponent
      t.string :symbol
      t.timestamps
    end
    add_index :system_currencies, :public_id, unique: true
    add_index :system_currencies, :code,      unique: true
  end
end
