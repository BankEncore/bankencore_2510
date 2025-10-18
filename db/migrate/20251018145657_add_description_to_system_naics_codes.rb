# db/migrate/20251018173000_align_naics_schema.rb
class AlignNaicsSchema < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_column :system_naics_codes, :description, :text unless column_exists?(:system_naics_codes, :description)
    add_column :system_naics_codes, :sector, :string, limit: 2 unless column_exists?(:system_naics_codes, :sector)
    add_column :system_naics_codes, :active, :boolean, default: true, null: false unless column_exists?(:system_naics_codes, :active)
    change_column :system_naics_codes, :year, :string unless columns(:system_naics_codes)["year"].sql_type =~ /character/
    add_index :system_naics_codes, [ :year, :code ], unique: true, name: :index_system_naics_codes_on_year_and_code, algorithm: :concurrently unless index_exists?(:system_naics_codes, [ :year, :code ], unique: true)
    add_index :system_naics_codes, [ :year, :sector ], name: :index_system_naics_codes_on_year_and_sector, algorithm: :concurrently unless index_exists?(:system_naics_codes, [ :year, :sector ])
    add_index :system_naics_codes, [ :year, :parent_code ], name: :index_system_naics_codes_on_year_and_parent, algorithm: :concurrently unless index_exists?(:system_naics_codes, [ :year, :parent_code ])
  end

  def down
    remove_index :system_naics_codes, name: :index_system_naics_codes_on_year_and_parent if index_exists?(:system_naics_codes, name: :index_system_naics_codes_on_year_and_parent)
    remove_index :system_naics_codes, name: :index_system_naics_codes_on_year_and_sector if index_exists?(:system_naics_codes, name: :index_system_naics_codes_on_year_and_sector)
    remove_index :system_naics_codes, name: :index_system_naics_codes_on_year_and_code if index_exists?(:system_naics_codes, name: :index_system_naics_codes_on_year_and_code)
    remove_column :system_naics_codes, :active if column_exists?(:system_naics_codes, :active)
    remove_column :system_naics_codes, :sector if column_exists?(:system_naics_codes, :sector)
    remove_column :system_naics_codes, :description if column_exists?(:system_naics_codes, :description)
  end

  private

  def columns(table)
    Hash[connection.columns(table).map { |c| [ c.name, c ] }]
  end
end
