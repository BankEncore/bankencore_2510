class AddPublicIds < ActiveRecord::Migration[8.0]
  def change
    add_column :system_reference_lists,    :public_id, :uuid unless column_exists?(:system_reference_lists, :public_id)
    add_column :system_reference_values,   :public_id, :uuid unless column_exists?(:system_reference_values, :public_id)
    add_column :system_naics_codes,        :public_id, :uuid unless column_exists?(:system_naics_codes, :public_id)
    add_column :system_country_currencies, :public_id, :uuid unless column_exists?(:system_country_currencies, :public_id)
  end
end
