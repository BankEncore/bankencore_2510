require "rails_helper"

RSpec.describe System::ReferenceList, type: :model do
  subject(:list) { build(:system_reference_list) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:name) }

  it "validates key uniqueness case-insensitive" do
    base = "status_#{SecureRandom.hex(3)}"
    create(:system_reference_list, key: base, name: "Status")
    dup = build(:system_reference_list, key: base.upcase, name: "Other")
    expect(dup).not_to be_valid
  end

  it "has many reference_values (restrict if configured)" do
    assoc = described_class.reflect_on_association(:reference_values)
    expect(assoc&.macro).to eq(:has_many)
  end

  it "normalizes key to downcase" do
    l = described_class.create!(key: "CustomerStatus", name: "Customer status")
    expect(l.reload.key).to eq("customerstatus")
  end
end
