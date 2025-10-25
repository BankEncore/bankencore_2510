files =
  if ENV["SEEDS"] # e.g. SEEDS="base_schema"
    ENV["SEEDS"].split(",").map { |n| "db/seeds/#{n}.rb" }
  else
    [ "db/seeds/000_seeds.rb" ] # default
  end

files.each do |rel|
  path = Rails.root.join(rel)
  if File.exist?(path)
    puts "==> Seeding: #{rel}"
    load path
  else
    warn "skip: #{rel} (not found)"
  end
end
