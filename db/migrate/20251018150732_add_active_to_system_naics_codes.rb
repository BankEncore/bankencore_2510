class AddActiveToSystemNaicsCodes < ActiveRecord::Migration[7.1]
  def change
    add_column :system_naics_codes, :active, :boolean, null: false, default: true unless column_exists?(:system_naics_codes, :active)
    add_index  :system_naics_codes, [:year, :code], unique: true, name: :index_system_naics_codes_on_year_and_code unless index_exists?(:system_naics_codes, [:year, :code], unique: true)
  end
end
