class CreateSystemNaicsCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :system_naics_codes do |t|
      t.uuid :public_id, default: "gen_random_uuid()", null: false
      t.integer :year,     null: false, default: 2022
      t.string  :code,     null: false                  # 2–6 digits
      t.string  :title,    null: false
      t.string  :sector                               # optional parsed sector name
      t.string  :parent_code                          # for hierarchy
      t.integer :level,   null: false                 # 2..6
      t.timestamps
    end
    add_index :system_naics_codes, :public_id, unique: true
    add_index :system_naics_codes, [ :year, :code ], unique: true
    add_index :system_naics_codes, [ :year, :parent_code ]
  end
end
