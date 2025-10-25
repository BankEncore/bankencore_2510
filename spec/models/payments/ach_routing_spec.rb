require "rails_helper"

RSpec.describe Payments::AchRouting, type: :model do
  describe "normalization" do
    it "pads routing_number to 9 digits" do
      r = described_class.create!(routing_number: "518", customer_name: "X",
        city: "A", state_code: "PA", servicing_frb_number: "031000040", office_code: "1")
      expect(r.routing_number).to eq("000000518")
    end

    it "normalizes servicing_frb_number to 9 digits" do
      good = described_class.create!(routing_number: "110000001", customer_name: "X",
        city: "PHL", state_code: "PA", servicing_frb_number: "123", office_code: "1")
      expect(good.servicing_frb_number).to eq("000000123")
    end
  end

  it "normalizes office_code to 'O' or 'B'" do
    o = described_class.create!(routing_number: "110000002", customer_name: "X",
      city: "PHL", state_code: "PA", servicing_frb_number: "031000040", office_code: "0")
    b = described_class.create!(routing_number: "110000003", customer_name: "X",
      city: "PHL", state_code: "PA", servicing_frb_number: "031000040", office_code: "1")
    expect(%w[O B]).to include(o.office_code)
    expect(%w[O B]).to include(b.office_code)
  end

  # spec/models/payments/ach_routing_spec.rb
  it "returns label/class pairs for the supported booleans" do
    r = build(:payments_ach_routing, us_treasury: true, us_postal_service: true,
      federal_reserve_bank: false, on_us: true, special_handling: false)
    labels = r.flags.map(&:first)
    expect(labels).to include("U.S. Treasury", "USPS Money Order", "On Us")
    expect(labels).not_to include("Federal Reserve Bank", "Special Handling")
  end
end
