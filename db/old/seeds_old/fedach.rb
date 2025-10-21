# db/seeds/fedach.rb
# frozen_string_literal: true

PATH = Rails.root.join("db/seeds/data/FedACHdir.txt")

def slice(s, a, b) = s && s.byteslice(a-1, b-a+1).to_s # 1-based inclusive
def s(s, a, b, max = nil) = slice(s, a, b).strip.then { |v| max ? v[0, max] : v }
def d(s, a, b, max = nil) = slice(s, a, b).gsub(/\D/, "").then { |v| max ? v[0, max] : v }
def mmddyy(v) = v.blank? ? nil : Date.strptime(v, "%m%d%y")

raise "Missing #{PATH}" unless File.exist?(PATH)

count = 0
File.foreach(PATH, encoding: "ISO-8859-1:utf-8") do |line|
  next if line.strip.empty?

  routing_number        = d(line,   1,  9, 9)
  office_code           = s(line,  10, 10, 1)
  servicing_frb_number  = d(line,  11, 19, 9).presence
  record_type_code      = s(line,  20, 20, 1)
  change_date           = mmddyy(s(line, 21, 26))
  new_routing_number    = d(line,  27, 35, 9).presence
  customer_name         = s(line,  36, 71, 36)
  address               = s(line,  72, 107, 36).presence
  city                  = s(line, 108, 127, 20).presence
  state_code_raw        = s(line, 128, 129, 2)
    state_code          = /\A[A-Z]{2}\z/.match?(state_code_raw) ? state_code_raw : nil
  zip5                  = s(line, 130, 134, 5)
  zip4                  = s(line, 135, 138, 4).presence
  phone_number          = d(line, 139, 148, 10).presence
  institution_status    = s(line, 149, 149, 1).presence
  data_view_code        = s(line, 150, 150, 1).presence

  Payments::AchRouting.upsert(
    {
      routing_number:,
      office_code:,
      servicing_frb_number:,
      record_type_code:,
      change_date:,
      new_routing_number:,
      customer_name:,
      address:,
      city:,
      state_code: state_code,
      zip_code: zip4 ? "#{zip5}-#{zip4}" : zip5,
      phone_number:,
      institution_status_code: institution_status,
      data_view_code: data_view_code,
      us_treasury: false,
      us_postal_service: false,
      federal_reserve_bank: false,
      on_us: false,
      local: false,
      special_handling: false,
      created_at: Time.current,
      updated_at: Time.current
    },
    unique_by: :routing_number
  )
  count += 1
end

puts "FedACH loaded rows: #{count}"
