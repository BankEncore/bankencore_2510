# 20251027001200_create_parties_secret_data.rb
class CreatePartiesSecretData < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_secret_data do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties_parties }
      t.string :secret_type, null: false
      t.string :secret_value, null: false                      # app-level encryption
      t.timestamps
    end

    add_index :parties_secret_data, [ :party_id, :secret_type ], unique: true
  end
end
