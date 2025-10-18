# spec/models/payments/ach_routing_spec.rb
require "rails_helper"

RSpec.describe Payments::AchRouting, type: :model do
  describe "defaults and normalization" do
    it "generates public_id and pads routing numbers" do
      r = described_class.create!(routing_number: "518", customer_name: "U.S. TREASURY",
                                  city: "ARLINGTON", state_code: "VA", servicing_frb_number: "31000040")
      expect(r.public_id).to be_present
      expect(r.routing_number).to eq("000000518")
      expect(r.servicing_frb_number).to eq("031000040")
      expect(r.new_routing_number).to eq("000000000")
      expect(r.record_type_code).to eq("0")
      expect(r.office_code).to eq("O")
      expect(r.institution_status_code).to eq("1")
      expect(r.data_view_code).to eq("1")
    end

    it "maps office_code digits to letters per constraint" do
      r = described_class.create!(routing_number: "031000040", customer_name: "X",
                                  city: "PHL", state_code: "PA", servicing_frb_number: "031000040",
                                  office_code: "1")
      expect(r.office_code).to eq("B")
    end
  end

  describe "#routing_changed?" do
    it "is false for 000000000 and true for any 9-digit other" do
      r = build(:payments_ach_routing, new_routing_number: "000000000")
      expect(r.routing_changed?).to be false
      r.new_routing_number = "123456789"
      expect(r.routing_changed?).to be true
    end
  end

    describe "#flags" do
    it "returns label/class pairs for true booleans" do
        r = build(:payments_ach_routing, us_treasury: true, on_us: true)
        labels = r.flags.map(&:first)
        expect(labels).to include("U.S. Treasury", "On Us")
        expect(labels).not_to include("Special Handling")
    end
    end

  describe "#frb_branch" do
    it "looks up FRB by servicing_frb_number" do
      r = build(:payments_ach_routing, servicing_frb_number: "031000040")
      b = r.frb_branch
      expect(b).to be_present
      expect(b.city).to eq("Philadelphia")
      expect(b.rtn).to eq("031000040")
    end
  end
end
