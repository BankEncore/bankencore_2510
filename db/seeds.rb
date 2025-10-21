def load_glob(glob)
  Dir[Rails.root.join(glob)].sort.each { |f| puts "Seeding: #{f}"; load f }
end

load_glob("db/seeds/system/**/*.rb")
load_glob("db/seeds/standards/countries.rb")
load_glob("db/seeds/standards/currencies.rb")
load_glob("db/seeds/standards/country_currencies.rb")
load_glob("db/seeds/standards/regions.rb")
load_glob("db/seeds/standards/naics.rb")
load_glob("db/seeds/payments/**/*.rb")
load_glob("db/seeds/data/**/*.rb")