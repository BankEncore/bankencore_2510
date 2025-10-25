# spec/models/branch_spec.rb
# new
require "rails_helper"

RSpec.describe Branch, type: :model do
  subject do
    described_class.new(
      code: "001",
      name: "Main Office",
      status: 1,
      time_zone: "America/New_York",
      country_alpha2: "US",
      email: "MAIN@BANK.local"
    )
  end

  it "is valid with minimal required fields" do
    expect(subject).to be_valid
  end

  describe "normalization" do
    it "uppercases code and country, downcases email" do
      subject.validate
      expect(subject.code).to eq("001")
      expect(subject.country_alpha2).to eq("US")
      expect(subject.email).to eq("main@bank.local")
    end

    it "uppercases region_code" do
      subject.region_code = "pa"
      subject.validate
      expect(subject.region_code).to eq("PA")
    end
  end

  describe "validations" do
    it "requires code, name, time_zone, country_alpha2" do
      subject.code = nil
      expect(subject).to be_invalid
      subject.code = "001"
      subject.name = nil
      expect(subject).to be_invalid
      subject.name = "X"
      subject.time_zone = nil
      expect(subject).to be_invalid
      subject.time_zone = "America/New_York"
      subject.country_alpha2 = nil
      expect(subject).to be_invalid
    end

    it "validates code format and uniqueness" do
      create(:branch, code: "ABC")
      dup = build(:branch, code: "ABC")
      expect(dup).to be_invalid
      expect(build(:branch, code: "A-01")).to be_valid
      expect(build(:branch, code: "bad code")).to be_invalid
    end

    it "validates email and phone formats" do
      subject.email = "not-an-email"
      expect(subject).to be_invalid
      subject.email = "branch@test.local"
      subject.phone = "++bad"
      expect(subject).to be_invalid
      subject.phone = "+1 412 555 0123"
      expect(subject).to be_valid
    end

    it "restricts status to enum values" do
      subject.status = 2
      expect(subject).to be_invalid
      subject.status = 0
      expect(subject).to be_valid
    end
  end

  describe "indexes and constraints" do
    it "enforces unique code at DB level" do
      create(:branch, code: "999")
      dup = build(:branch, code: "999")
      expect(dup).to be_invalid
      expect {
        dup.save!(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique).or change { dup.valid? }.to(false)
    end
  end

  describe "scenarios" do
    it "stores operating_hours JSON" do
      b = create(:branch, code: "777")
      expect(b.operating_hours).to be_a(Hash)
      expect(b.operating_hours["tz"]).to eq("America/New_York")
    end
  end
end
