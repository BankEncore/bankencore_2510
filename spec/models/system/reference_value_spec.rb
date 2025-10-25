# spec/models/system/reference_value_spec.rb
require "rails_helper"

RSpec.describe System::ReferenceValue, type: :model do
  let(:list) { create(:system_reference_list) }

  it "requires code uniqueness within list" do
    create(:system_reference_value, reference_list: list, code: "A", name: "Active")
    dup = build(:system_reference_value, reference_list: list, code: "A", name: "Another")
    expect(dup).not_to be_valid
  end

  it "scopes active values" do
    a1 = create(:system_reference_value, reference_list: list, code: "A", name: "Active",  active: true)
    a2 = create(:system_reference_value, reference_list: list, code: "B", name: "Blocked", active: false)
    expect(described_class.active).to include(a1)
    expect(described_class.active).not_to include(a2)
  end
end
