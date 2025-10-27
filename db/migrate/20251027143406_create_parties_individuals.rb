# db/migrate/20251027143406_create_parties_individuals.rb
class CreatePartiesIndividuals < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_individuals, id: false do |t|
      t.references :party, null: false, index: { unique: true }, foreign_key: { to_table: :parties_parties }
      t.string  :residence_country
      t.date    :birth_date
      t.string  :gender_code
      t.string  :marital_status_code
      t.string  :immigration_status_code
      t.string  :education_level_code
      t.string  :home_ownership_code
      t.string  :race_code
      t.string  :employment_type_code
      t.string  :occupation_code
      t.timestamps
    end

    add_index :parties_individuals, :residence_country
    add_foreign_key :parties_individuals, :system_countries,
      column: :residence_country, primary_key: :alpha2, validate: false
  end
end
