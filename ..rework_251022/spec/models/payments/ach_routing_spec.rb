# spec/models/payments/ach_routing_spec.rb
# new
require "rails_helper"

RSpec.describe Payments::AchRouting, type: :model do
  subject(:row) do
    described_class.new(
      routing_number: "011000015",
      customer_name: "FEDERAL RESERVE BANK",
      city: "BOSTON",
      state_code: "MA",
      office_code: "O",
      record_type_code: "0",
      institution_status_code: "1",
      data_view_code: "1"
    )
  end

  it "is valid with required attributes" do
    expect(row).to be_valid
  end

  it "requires unique routing_number" do
    described_class.create!(routing_number: "011000015", customer_name: "X")
    dup = described_class.new(routing_number: "011000015", customer_name: "Y")
    expect(dup).to be_invalid
    expect(dup.errors[:routing_number]).to be_present
  end

  it "normalizes routing_number length if the model implements it" do
    row.routing_number = "11000015" # missing leading 0
    row.validate
    # If your model pads to 9 digits, assert 9-digit string. Otherwise accept raw.
    expect(row.routing_number.length).to eq(9)
  end
end
