# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
# Seed NAICS codes from CSV
def load_seed_glob(glob)
  Dir[Rails.root.join(glob)].sort.each do |f|
    puts "Seeding: #{f}"
    load f
  end
end

require Rails.root.join("app/services/system/naics_importer")
naics_path = Rails.root.join("db/seeds/data/naics_2to6.csv")
if File.exist?(naics_path)
  count = System::NaicsImporter.run(path: naics_path.to_s, year: "2022")
  puts "NAICS seeded: #{count} rows"
else
  puts "NAICS CSV not found at #{naics_path}"
end
load Rails.root.join("db/seeds/countries_regions_from_gems.rb")
load Rails.root.join("db/seeds/fedach.rb") unless Rails.env.test?
load Rails.root.join("db/seeds/currencies.rb")
load Rails.root.join("db/seeds/references.rb")
load Rails.root.join("db/seeds/data/branches.rb")


#   end
