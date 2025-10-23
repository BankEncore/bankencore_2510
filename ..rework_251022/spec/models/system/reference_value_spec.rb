# spec/models/system/reference_value_spec.rb
# new
require "rails_helper"

RSpec.describe System::ReferenceValue, type: :model do
  let(:list) { create(:system_reference_list, key: "statuses") }
  subject(:value) { build(:system_reference_value, reference_list: list, code: "active") }

  it "is valid with default factory" do
    expect(value).to be_valid
  end

  it "enforces uniqueness of code within list (case-insensitive)" do
    create(:system_reference_value, reference_list: list, code: "ACTIVE")
    dup = build(:system_reference_value, reference_list: list, code: "active")
    expect(dup).not_to be_valid
    expect(dup.errors[:code]).to be_present
  end

  it "normalizes fields on validation" do
    value.code = "  v-1  "
    value.short_name = "  s  "
    value.validate
    expect(value.code).to eq("v-1")
    expect(value.short_name).to eq("s")
  end

  it "requires valid validity window" do
    value.valid_from = Date.new(2025,1,2)
    value.valid_to   = Date.new(2025,1,1)
    expect(value).to be_invalid
    expect(value.errors[:valid_to]).to be_present
  end

  describe ".search" do
    it "matches by code, name, short_name, or description" do
      target = create(:system_reference_value, reference_list: list, code: "blue", name: "Blue")
      expect(System::ReferenceValue.search("blu")).to include(target)
    end
  end
end
