# db/seeds/standards/regions.rb
now = Time.current

region_cols = System::Region.column_names
code_col  = (%w[code region_code] & region_cols).first or raise "regions: no code column"
local_col = (%w[local_code abbr short_code] & region_cols).first
name_col  = (%w[name title label] & region_cols).first or raise "regions: no name column"
type_col  = (%w[type_name kind category] & region_cols).first
has_meta  = region_cols.include?("metadata")
has_active= region_cols.include?("active")

# Determine the country foreign key via the association if present
assoc      = System::Region.reflect_on_association(:country)
country_fk = assoc&.foreign_key || (%w[country_alpha2 country_id system_country_id country_code] & region_cols).first
raise "regions: no country FK detected" unless country_fk

# Map US/CA to what the FK expects
if country_fk == "country_alpha2" || country_fk == "country_code"
  COUNTRY_VALUE = { "US" => "US", "CA" => "CA" }
elsif country_fk == "country_id" || country_fk == "system_country_id"
  c2 = (System::Country.column_names & %w[alpha2 iso2]).first or raise "countries: no alpha2/iso2"
  ids = System::Country.where(c2 => %w[US CA]).pluck(c2, :id).to_h
  raise "countries missing: #{(%w[US CA] - ids.keys).join(', ')}" unless (%w[US CA] - ids.keys).empty?
  COUNTRY_VALUE = { "US" => ids["US"], "CA" => ids["CA"] }
else
  raise "unsupported country FK: #{country_fk}"
end

US = {
  "AL"=>"Alabama","AK"=>"Alaska","AZ"=>"Arizona","AR"=>"Arkansas","CA"=>"California","CO"=>"Colorado",
  "CT"=>"Connecticut","DE"=>"Delaware","FL"=>"Florida","GA"=>"Georgia","HI"=>"Hawaii","ID"=>"Idaho",
  "IL"=>"Illinois","IN"=>"Indiana","IA"=>"Iowa","KS"=>"Kansas","KY"=>"Kentucky","LA"=>"Louisiana",
  "ME"=>"Maine","MD"=>"Maryland","MA"=>"Massachusetts","MI"=>"Michigan","MN"=>"Minnesota",
  "MS"=>"Mississippi","MO"=>"Missouri","MT"=>"Montana","NE"=>"Nebraska","NV"=>"Nevada",
  "NH"=>"New Hampshire","NJ"=>"New Jersey","NM"=>"New Mexico","NY"=>"New York","NC"=>"North Carolina",
  "ND"=>"North Dakota","OH"=>"Ohio","OK"=>"Oklahoma","OR"=>"Oregon","PA"=>"Pennsylvania",
  "RI"=>"Rhode Island","SC"=>"South Carolina","SD"=>"South Dakota","TN"=>"Tennessee","TX"=>"Texas",
  "UT"=>"Utah","VT"=>"Vermont","VA"=>"Virginia","WA"=>"Washington","WV"=>"West Virginia",
  "WI"=>"Wisconsin","WY"=>"Wyoming","DC"=>"District of Columbia"
}
CA = {
  "AB"=>"Alberta","BC"=>"British Columbia","MB"=>"Manitoba","NB"=>"New Brunswick",
  "NL"=>"Newfoundland and Labrador","NS"=>"Nova Scotia","NT"=>"Northwest Territories",
  "NU"=>"Nunavut","ON"=>"Ontario","PE"=>"Prince Edward Island","QC"=>"Quebec",
  "SK"=>"Saskatchewan","YT"=>"Yukon"
}

def make_row(cc:, lc:, name:, code_col:, local_col:, name_col:, type_col:, has_meta:, has_active:, country_fk:)
  h = {
    code_col => "#{cc}-#{lc}",
    name_col => name,
    country_fk => COUNTRY_VALUE.fetch(cc),
    created_at: Time.current,
    updated_at: Time.current
  }
  h[local_col] = lc if local_col
  h[type_col]  = (cc=="US" && lc=="DC") ? "district" : (%w[NT NU YT].include?(lc) ? "territory" : (cc=="US" ? "state" : "province")) if type_col
  h[:metadata] = {} if has_meta
  h[:active]   = true if has_active
  h
end

rows = []
US.each { |lc,nm| rows << make_row(cc: "US", lc:, name: nm, code_col:, local_col:, name_col:, type_col:, has_meta:, has_active:, country_fk:) }
CA.each { |lc,nm| rows << make_row(cc: "CA", lc:, name: nm, code_col:, local_col:, name_col:, type_col:, has_meta:, has_active:, country_fk:) }

# Upsert if a unique index on code exists; else idempotent row-by-row
idx = ActiveRecord::Base.connection.indexes("system_regions").find { |i| i.unique && i.columns.map(&:to_s) == [code_col] }

if idx
  System::Region.upsert_all(rows, unique_by: idx.name.to_sym)
else
  rows.each do |r|
    rec = System::Region.where(code_col => r[code_col.to_sym]).first_or_initialize
    rec.assign_attributes(r.except(code_col.to_sym))
    rec.save! # will satisfy "Country must exist"
  end
end

puts "Regions: #{System::Region.count} (country FK: #{country_fk}, code col: #{code_col})"
