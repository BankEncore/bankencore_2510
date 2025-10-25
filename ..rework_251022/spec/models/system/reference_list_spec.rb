# spec/models/system/reference_list_spec.rb
# new
require "rails_helper"

RSpec.describe System::ReferenceList, type: :model do
  subject(:list) { build(:system_reference_list) }

  it "is valid with default factory" do
    expect(list).to be_valid
  end

  it "normalizes and validates key" do
    list.key = "  My Key! "
    list.validate
    expect(list.key).to eq("my-key-")
    expect(list).to be_valid
  end

  it "enforces unique key (case-insensitive)" do
    create(:system_reference_list, key: "tax.codes")
    dup = build(:system_reference_list, key: "Tax.Codes")
    expect(dup).not_to be_valid
    expect(dup.errors[:key]).to be_present
  end

  describe ".search" do
    it "matches by key or name or description" do
      target = create(:system_reference_list, key: "colors", name: "Colors", description: "basic")
      create(:system_reference_list, key: "fruits")
      expect(System::ReferenceList.search("color")).to include(target)
    end
  end

  it "has many values with restrict delete" do
    list = create(:system_reference_list)
    create(:system_reference_value, reference_list: list)
    expect { list.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
  end
end
