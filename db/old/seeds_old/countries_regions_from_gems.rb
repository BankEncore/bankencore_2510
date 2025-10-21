# frozen_string_literal: true

require "countries"
require "carmen"

def pick(*vals) = vals.find { |v| v.present? }

def upsert_country(c)
  d = c.data # raw hash

  name          = pick(d["name"], d["iso_short_name"], d["official_name"], d["common_name"])
  official_name = pick(d["official_name"], d["iso_long_name"], d["common_name"], name)
  # country code can be string or array; ensure "+<digits>"
  cc_raw = Array(d["country_code"] || d["country_codes"]).first.to_s.strip
  calling = cc_raw.empty? ? nil : (cc_raw.start_with?("+") ? cc_raw : "+#{cc_raw}")
  # currency can be string or array under different keys
  cur = Array(d["currency"] || d["currencies"]).first
  # TLD key varies
  tlds = Array(d["tld"] || d["tlds"])

  rec = System::Country.find_or_initialize_by(iso2: c.alpha2)
  rec.iso3          = c.alpha3
  rec.numeric       = d["number"].to_s.presence
  rec.name          = name || "Unknown #{c.alpha2}"
  rec.official_name = official_name || rec.name
  rec.calling_code  = calling
  rec.currency_code = cur.to_s[0, 3].presence
  rec.region        = d["region"]
  rec.subregion     = d["subregion"]
  rec.tlds          = tlds
  rec.active        = true
  rec.save!
end

def upsert_regions_for(iso2)
  co = Carmen::Country.coded(iso2)
  return unless co
  sc = System::Country.find_by!(iso2: iso2)
  co.subregions.each do |sr|
    rec = System::Region.find_or_initialize_by(system_country_id: sc.id, code: sr.code)
    rec.name       = sr.name
    rec.type_name  = sr.type.presence || "state"
    rec.iso_3166_2 = "#{iso2}-#{sr.code}"
    rec.active     = true
    rec.save!
  end
end

ISO3166::Country.all.each { |c| upsert_country(c) }
ISO3166::Country.all.each { |c| upsert_regions_for(c.alpha2) }
puts "Seeded countries: #{System::Country.count}, regions: #{System::Region.count}"
