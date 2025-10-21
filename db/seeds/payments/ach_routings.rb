# db/seeds/payments/ach_routings.rb
# Modes:
#   default: load small sample set
#   SEED_ACH=1 ACH_PATH=/path/to/FedACHdir.txt  -> parse fixed-width FedACH file
#
# Table: payments_ach_routings
# Columns used: routing_number, customer_name, city, state_code, servicing_frb_number,
#               office_code, record_type_code, institution_status_code, data_view_code,
#               new_routing_number, public_id, timestamps
#
# Unique index expected on :routing_number

def upsert_ach(rows)
  return if rows.empty?
  now = Time.current
  rows = rows.map { |r| r.merge(created_at: now, updated_at: now) }
  Payments::AchRouting.upsert_all(rows, unique_by: :index_payments_ach_routings_on_routing_number)
end

def pad9(s)
  s = s.to_s.strip
  s.empty? ? nil : format("%09d", s.to_i)
end

def parse_fedach_line(line)
  # Fixed-width spec (common FedACH DIR layout)
  #  1– 9: Routing Number
  # 10   : Office Code
  # 11–19: Servicing FRB Number
  # 20   : Record Type Code
  # 21   : Change Date (YYMMDD)           [ignored]
  # 22–36: New Routing Number
  # 37–71: Customer Name
  # 72–91: City
  # 92–93: State Code
  # 94–98: Zip Code                       [ignored]
  # 99–103: Zip Ext                       [ignored]
  # 104  : Institution Status Code
  # 105  : Data View Code
  rn   = line[0,9]
  return nil if rn.nil? || rn.strip.empty? # skip blanks
  {
    routing_number:        pad9(rn),
    office_code:           line[9,1]&.strip,
    servicing_frb_number:  pad9(line[10,9]),
    record_type_code:      line[19,1]&.strip,
    new_routing_number:    pad9(line[20,15]),
    customer_name:         line[36,35]&.rstrip,
    city:                  line[71,20]&.rstrip,
    state_code:            line[91,2]&.strip,
    institution_status_code: line[103,1]&.strip,
    data_view_code:        line[104,1]&.strip
  }
end

def load_fedach(path)
  rows = []
  File.foreach(path, encoding: "ISO-8859-1") do |line|
    line = line.to_s
    next if line.strip.empty?
    h = parse_fedach_line(line)
    rows << h if h
    # batch to avoid huge SQL
    if rows.size >= 2_000
      upsert_ach(rows)
      rows.clear
    end
  end
  upsert_ach(rows)
end

ActiveRecord::Base.transaction do
  if ENV["SEED_ACH"] == "1"
    path = ENV["ACH_PATH"] || Rails.root.join("db", "seed_data", "FedACHdir.txt").to_s
    raise "ACH file not found at #{path}" unless File.exist?(path)
    load_fedach(path)
  else
    # Deterministic minimal sample
    sample = [
      { routing_number: "031000053", customer_name: "PNC BANK, NA",     city: "PITTSBURGH", state_code: "PA",
        servicing_frb_number: "031000014", office_code: "O", record_type_code: "1",
        institution_status_code: "1", data_view_code: "1", new_routing_number: nil },
      { routing_number: "121000358", customer_name: "BANK OF AMERICA",  city: "SAN FRANCISCO", state_code: "CA",
        servicing_frb_number: "121000037", office_code: "O", record_type_code: "1",
        institution_status_code: "1", data_view_code: "1", new_routing_number: nil },
      { routing_number: "026009593", customer_name: "BANK OF AMERICA",  city: "NEW YORK", state_code: "NY",
        servicing_frb_number: "021000120", office_code: "O", record_type_code: "1",
        institution_status_code: "1", data_view_code: "1", new_routing_number: nil },
      { routing_number: "064000101", customer_name: "REGIONS BANK",     city: "BIRMINGHAM", state_code: "AL",
        servicing_frb_number: "061000014", office_code: "O", record_type_code: "1",
        institution_status_code: "1", data_view_code: "1", new_routing_number: nil },
      { routing_number: "011000028", customer_name: "BANK OF AMERICA",  city: "BOSTON", state_code: "MA",
        servicing_frb_number: "011000001", office_code: "O", record_type_code: "1",
        institution_status_code: "1", data_view_code: "1", new_routing_number: nil }
    ]
    upsert_ach(sample)
  end
end

puts "ACH routings: #{Payments::AchRouting.count}"
