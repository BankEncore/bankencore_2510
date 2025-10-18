# spec/models/payments/frb_directory_spec.rb
require "rails_helper"

RSpec.describe Payments::FrbDirectory do
  it "returns a Branch for known RTN and nil for unknown" do
    b = described_class.lookup("031000040")
    expect(b).to be_present
    expect(b.city).to eq("Philadelphia")
    expect(described_class.lookup("999999999")).to be_nil
  end
end
