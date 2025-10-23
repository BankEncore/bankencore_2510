# spec/models/system/naics_code_spec.rb
# new
require "rails_helper"

RSpec.describe System::NaicsCode, type: :model do
  subject(:naics) { build(:system_naics_code) }

  it "is valid with default factory" do
    expect(naics).to be_valid
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:version) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:level) }

    it "enforces uniqueness on [version, code]" do
      create(:system_naics_code, version: "2022", code: "541511")
      dup = build(:system_naics_code, version: "2022", code: "541511")
      expect(dup).not_to be_valid
      expect(dup.errors[:code]).to be_present
    end
  end

  describe "scopes" do
    it "orders by code within version" do
      a = create(:system_naics_code, version: "2022", code: "11")
      b = create(:system_naics_code, version: "2022", code: "21")
      expect(System::NaicsCode.where(version: "2022").order(:code)).to eq([a, b])
    end
  end

  describe "hierarchy" do
    it "finds parent by parent_code within the same version" do
      parent = create(:system_naics_code, version: "2022", code: "54", level: 2)
      child  = create(:system_naics_code, version: "2022", code: "541", parent_code: "54", level: 3)
      expect(System::NaicsCode.find_by(version: child.version, code: child.parent_code)).to eq(parent)
    end
  end
end
