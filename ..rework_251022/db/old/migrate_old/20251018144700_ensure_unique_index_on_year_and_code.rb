# db/migrate/20251018160000_ensure_unique_index_on_year_and_code.rb
class EnsureUniqueIndexOnYearAndCode < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Already correct
    if index_exists?(:system_naics_codes, [ :year, :code ],
                     name: :index_system_naics_codes_on_year_and_code,
                     unique: true)
      return
    end

    # Drop any conflicting index (by name or by columns)
    if index_exists?(:system_naics_codes, name: :index_system_naics_codes_on_year_and_code)
      remove_index :system_naics_codes,
                   name: :index_system_naics_codes_on_year_and_code,
                   algorithm: :concurrently
    elsif index_exists?(:system_naics_codes, [ :year, :code ])
      remove_index :system_naics_codes,
                   column: [ :year, :code ],
                   algorithm: :concurrently
    end

    add_index :system_naics_codes, [ :year, :code ],
              unique: true,
              name: :index_system_naics_codes_on_year_and_code,
              algorithm: :concurrently
  end

  def down
    remove_index :system_naics_codes,
                 name: :index_system_naics_codes_on_year_and_code,
                 algorithm: :concurrently if index_exists?(:system_naics_codes, name: :index_system_naics_codes_on_year_and_code)

    add_index :system_naics_codes, [ :year, :code ],
              algorithm: :concurrently unless index_exists?(:system_naics_codes, [ :year, :code ])
  end
end
