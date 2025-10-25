class CreateSystemCountryCurrencies < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :system_country_currencies, id: :bigint do |t|
      t.uuid    :public_id, null: false, default: "gen_random_uuid()"
      t.bigint  :country_id, null: false                 # -> system_countries.id
      t.bigint  :currency_id, null: false                # -> system_currencies.id
      t.boolean :default_for_country, null: false, default: true
      t.date    :valid_from
      t.date    :valid_to
      t.timestamps
    end

    add_index :system_country_currencies, :public_id, unique: true
    add_index :system_country_currencies, [ :country_id, :currency_id ],
              unique: true, name: "idx_scc_on_country_currency"
    add_index :system_country_currencies, :country_id,
              where: "default_for_country", name: "idx_scc_default_per_country"

    add_check_constraint :system_country_currencies,
      "(valid_to IS NULL OR valid_from IS NULL OR valid_from <= valid_to)",
      name: "chk_scc_valid_window"

    add_foreign_key :system_country_currencies, :system_countries,
      column: :country_id, validate: false
    add_foreign_key :system_country_currencies, :system_currencies,
      column: :currency_id, validate: false
  end
end
