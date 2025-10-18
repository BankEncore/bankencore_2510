# lib/tasks/naics.rake
namespace :naics do
  desc "Import 2–6 digit NAICS CSV: rails 'naics:import[/path/file.csv,2022]'"
  task :import, [:csv_path, :year] => :environment do |_t, args|
    path = args[:csv_path] or abort "csv_path required"
    year = (args[:year] || "2022").to_s
    count = System::NaicsImporter.run(path: path, year: year)
    puts "Imported #{count} rows for #{year}"
  end
end
