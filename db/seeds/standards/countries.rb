# db/seeds/standards/countries.rb
now = Time.current
cols = System::Country.column_names

code2 = (cols & %w[alpha2 iso2]).first or raise "no 2-letter column"
code3 = (cols & %w[alpha3 iso3]).first or raise "no 3-letter column"
namec = (cols & %w[name title label]).first or raise "no name column"
has_numeric  = cols.include?("numeric")
has_metadata = cols.include?("metadata")
has_active   = cols.include?("active")

def row(code2:, code3:, numeric:, name:, now:, namec:, has_numeric:, has_metadata:, has_active:)
  h = { code2.first => code2.last, code3.first => code3.last, namec => name,
        created_at: now, updated_at: now }
  h[:numeric]  = numeric if has_numeric
  h[:metadata] = {}      if has_metadata
  h[:active]   = true    if has_active
  h
end

rows = [
  row(code2: [code2, "US"], code3: [code3, "USA"], numeric: "840", name: "United States of America",
      now:, namec:, has_numeric:, has_metadata:, has_active:),
  row(code2: [code2, "CA"], code3: [code3, "CAN"], numeric: "124", name: "Canada",
      now:, namec:, has_numeric:, has_metadata:, has_active:)
]

# Prefer a unique index on the detected 2-letter column if present
idx = ActiveRecord::Base.connection.indexes("system_countries").find { |i| i.unique && i.columns == [code2] }

if idx
  System::Country.upsert_all(rows, unique_by: idx.name.to_sym)
else
  rows.each do |r|
    key = r[code2.to_sym]
    rec = System::Country.where(code2 => key).first_or_initialize
    rec.assign_attributes(r.except(code2.to_sym))
    rec.save!
  end
end

puts "Countries: #{System::Country.count} (key: #{code2})"
