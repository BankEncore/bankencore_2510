# db/migrate/20251018150039_align_naics_schema.rb
class AlignNaicsSchema < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # add missing columns safely
    add_column :system_naics_codes, :description, :text unless column_exists?(:system_naics_codes, :description)
    add_column :system_naics_codes, :sector, :string, limit: 2 unless column_exists?(:system_naics_codes, :sector)
    add_column :system_naics_codes, :active, :boolean, default: true, null: false unless column_exists?(:system_naics_codes, :active)

    # SAFELY migrate year -> string without change_column
    if column_exists?(:system_naics_codes, :year) && !string_column?(:system_naics_codes, :year)
      add_column :system_naics_codes, :year_tmp, :string

      say_with_time "Backfilling year_tmp from year" do
        System::NaicsCode.in_batches(of: 10_000) do |rel|
          rel.update_all('year_tmp = year::text')
        end
      end

      # move writes/reads: rename columns
      rename_column :system_naics_codes, :year, :year_old
      rename_column :system_naics_codes, :year_tmp, :year

      # indexes referencing (year, code) must exist on the new column name
      unless index_exists?(:system_naics_codes, [ :year, :code ], unique: true, name: :index_system_naics_codes_on_year_and_code)
        add_index :system_naics_codes, [ :year, :code ],
                  unique: true, name: :index_system_naics_codes_on_year_and_code, algorithm: :concurrently
      end

      # drop the old integer column after swap
      remove_column :system_naics_codes, :year_old
    end

    # helpful supporting indexes (idempotent)
    add_index :system_naics_codes, [ :year, :sector ],
              name: :index_system_naics_codes_on_year_and_sector,
              algorithm: :concurrently unless index_exists?(:system_naics_codes, [ :year, :sector ], name: :index_system_naics_codes_on_year_and_sector)

    add_index :system_naics_codes, [ :year, :parent_code ],
              name: :index_system_naics_codes_on_year_and_parent,
              algorithm: :concurrently unless index_exists?(:system_naics_codes, [ :year, :parent_code ], name: :index_system_naics_codes_on_year_and_parent)
  end

  def down
    remove_index :system_naics_codes, name: :index_system_naics_codes_on_year_and_parent rescue nil
    remove_index :system_naics_codes, name: :index_system_naics_codes_on_year_and_sector rescue nil
    remove_column :system_naics_codes, :active if column_exists?(:system_naics_codes, :active)
    remove_column :system_naics_codes, :sector if column_exists?(:system_naics_codes, :sector)
    remove_column :system_naics_codes, :description if column_exists?(:system_naics_codes, :description)

    # reverse year swap only if feasible (optional no-op)
    # You can leave it as string; avoiding a blocking change back.
  end

  private

  def string_column?(table, column)
    connection.columns(table).find { |c| c.name == column.to_s }&.sql_type&.match?(/char|text/i)
  end
end
