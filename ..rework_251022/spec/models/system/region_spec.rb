# spec/models/system/region_spec.rb
# new
require "rails_helper"

RSpec.describe System::Region, type: :model do
  let!(:us) { System::Country.create!(alpha2: "US", alpha3: "USA", numeric: "840", iso_short_name: "United States of America") }

  it "is valid with minimal required fields" do
    r = described_class.new(country_alpha2: "US", region_code: "AK", name: "Alaska", kind: "state")
    expect(r).to be_valid
    r.save!
    expect(r.iso_code).to eq("US-AK")
  end

  it "normalizes case and builds iso_code" do
    r = described_class.create!(country_alpha2: "us", region_code: "ak", name: "Alaska", kind: "STATE")
    expect(r.country_alpha2).to eq("US")
    expect(r.region_code).to eq("AK")
    expect(r.kind).to eq("state")
    expect(r.iso_code).to eq("US-AK")
  end

  it "enforces uniqueness per country" do
    described_class.create!(country_alpha2: "US", region_code: "AK", name: "Alaska", kind: "state")
    dup = described_class.new(country_alpha2: "US", region_code: "AK", name: "Alaska 2", kind: "state")
    expect(dup).to be_invalid
  end

  it "rejects unsupported kinds" do
    r = described_class.new(country_alpha2: "US", region_code: "ZZ", name: "X", kind: "foobar")
    expect(r).to be_invalid
    r.kind = "state"
    expect(r).to be_valid
  end

  it "validates format constraints" do
    r = described_class.new(country_alpha2: "U", region_code: "AK", name: "Alaska", kind: "state")
    expect(r).to be_invalid
    r.country_alpha2 = "US"
    r.region_code = "a k"
    expect(r).to be_invalid
    r.region_code = "A-K"
    expect(r).to be_valid
  end

  context "db uniqueness constraint" do
    it "raises on duplicate insert when validations bypassed" do
      described_class.create!(country_alpha2: "US", region_code: "CA", name: "California", kind: "state")
      dup = described_class.new(country_alpha2: "US", region_code: "CA", name: "Duplicate", kind: "state")
      expect {
        dup.save!(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique).or change { dup.valid? }.to(false)
    end
  end
end
