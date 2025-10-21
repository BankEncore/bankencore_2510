# db/seeds/standards/naics.rb
now  = Time.current
cols = System::NaicsCode.column_names

CODE   = "code"
TITLE  = (%w[title name label] & cols).first or raise "naics: no title column"
DESC   = (%w[description details] & cols).first
PARENT = (%w[parent_code parent] & cols).first
LEVEL  = (%w[level depth] & cols).first or raise "naics: no level column"
SECTOR = (%w[sector] & cols).first
ACTIVE = (%w[active enabled] & cols).first
VER    = (%w[version year] & cols).first # optional

def r(code:, title:, level:, parent: nil, desc: nil, sector: nil, ver: nil)
  { "code"=>code, "title"=>title, "level"=>level, "parent_code"=>parent, "description"=>desc, "sector"=>sector, "version"=>ver }
end

ver = VER ? "2022" : nil
raw = [
  r(code:"11",     title:"Agriculture, Forestry, Fishing and Hunting", level:2, sector:"11", ver:ver),
  r(code:"21",     title:"Mining, Quarrying, and Oil and Gas Extraction", level:2, sector:"21", ver:ver),
  r(code:"31",     title:"Manufacturing", level:2, sector:"31", ver:ver),
  r(code:"311",    title:"Food Manufacturing", level:3, parent:"31", ver:ver),
  r(code:"3118",   title:"Bakeries and Tortilla Manufacturing", level:4, parent:"311", ver:ver),
  r(code:"31181",  title:"Bread and Bakery Product Manufacturing", level:5, parent:"3118", ver:ver),
  r(code:"311811", title:"Retail Bakeries", level:6, parent:"31181", desc:"Retail bakeries engaged primarily in selling baked goods made on premises.", ver:ver)
]

# Map to actual columns and unify keys
template = {
  CODE=>nil, TITLE=>nil, LEVEL=>nil,
  (PARENT||"__drop__")=>nil, (DESC||"__drop__")=>nil, (SECTOR||"__drop__")=>nil, (VER||"__drop__")=>nil,
  "created_at"=>now, "updated_at"=>now
}.reject { |k,_| k=="__drop__" }

rows = raw.map do |h|
  {
    CODE        => h["code"],
    TITLE       => h["title"],
    LEVEL       => h["level"],
    (PARENT if PARENT) => h["parent"],
    (DESC   if DESC)   => h["description"],
    (SECTOR if SECTOR) => h["sector"],
    (VER    if VER)    => h["version"],
    "created_at" => now, "updated_at" => now
  }.compact.then { |mapped| template.merge(mapped) } # ensures identical keys
end

# Unique key: [:version, :code] if VER exists, else [:code]
key_cols = VER ? [VER, CODE] : [CODE]
idx = ActiveRecord::Base.connection.indexes("system_naics_codes").find { |i| i.unique && i.columns.map(&:to_s) == key_cols }

if idx
  System::NaicsCode.upsert_all(rows, unique_by: idx.name.to_sym)
else
  rows.each do |r|
    where = r.slice(*key_cols)
    rec = System::NaicsCode.where(where).first_or_initialize
    rec.assign_attributes(r.except(*key_cols))
    rec.save!
  end
end

puts "NAICS rows: #{System::NaicsCode.count} (key: #{key_cols.join('+')})"
