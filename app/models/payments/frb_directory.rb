# app/lib/payments/frb_directory.rb
module Payments
  module FrbDirectory
    Branch = Struct.new(:district, :name, :phone, :rtn, :street, :city, :state, :zip, keyword_init: true)

    DATA = {
      "011000015"=> {district: "1st District",  name: "Federal Reserve Bank of Boston",        phone: "6179733000", rtn: "011000015", street: "600 Atlantic Ave",       city: "Boston",      state: "MA", zip: "02210"},
      "021001208"=> {district: "2nd District",  name: "Federal Reserve Bank of New York",      phone: "2127205000", rtn: "021001208", street: "33 Liberty St",          city: "New York",    state: "NY", zip: "10045"},
      "031000040"=> {district: "3rd District",  name: "Federal Reserve Bank of Philadelphia",  phone: "2155746000", rtn: "031000040", street: "Ten Independence Mall",  city: "Philadelphia", state: "PA", zip: "19106"},
      "041000014"=> {district: "4th District",  name: "Federal Reserve Bank of Cleveland",     phone: "2165792000", rtn: "041000014", street: "1455 E Sixth St",        city: "Cleveland",   state: "OH", zip: "44114"},
      "051000033"=> {district: "5th District",  name: "Federal Reserve Bank of Richmond",      phone: "8046978000", rtn: "051000033", street: "701 E Byrd St",          city: "Richmond",    state: "VA", zip: "23219"},
      "061000146"=> {district: "6th District",  name: "Federal Reserve Bank of Atlanta",       phone: "4044988500", rtn: "061000146", street: "1000 Peachtree St",      city: "Atlanta",     state: "GA", zip: "30303"},
      "071000301"=> {district: "7th District",  name: "Federal Reserve Bank of Chicago",       phone: "3123225322", rtn: "071000301", street: "230 S LaSalle St",       city: "Chicago",     state: "IL", zip: "60604"},
      "081000045"=> {district: "8th District",  name: "Federal Reserve Bank of St. Louis",     phone: "3144448444", rtn: "081000045", street: "411 Locust St",          city: "St. Louis",   state: "MO", zip: "63102"},
      "091000080"=> {district: "9th District",  name: "Federal Reserve Bank of Minneapolis",   phone: "6122045000", rtn: "091000080", street: "90 Hennepin Ave",        city: "Minneapolis", state: "MN", zip: "55401"},
      "101000048"=> {district: "10th District", name: "Federal Reserve Bank of Kansas City",   phone: "8168812000", rtn: "101000048", street: "1 Memorial Dr",         city: "Kansas City", state: "MO", zip: "64198"},
      "111000038"=> {district: "11th District", name: "Federal Reserve Bank of Dallas",        phone: "2149226000", rtn: "111000038", street: "2200 N Pearl St",       city: "Dallas",      state: "TX", zip: "75201"},
      "121000374"=> {district: "12th District", name: "Federal Reserve Bank of San Francisco", phone: "4159742000", rtn: "121000374", street: "101 Market St",         city: "San Francisco", state: "CA", zip: "94105"},
    }.transform_values! { |h| Branch.new(**h) }.freeze

    def self.lookup(rtn)
      return nil if rtn.blank?
      DATA[rtn.to_s.rjust(9, "0")]
    end
  end
end
