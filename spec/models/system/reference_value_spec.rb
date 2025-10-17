require "rails_helper"

RSpec.describe System::ReferenceValue, type: :model do
  it { is_expected.to belong_to(:reference_list).class_name("System::ReferenceList") }
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:label) }

  it "uses public_id for to_param" do
    v = build(:system_reference_value)
    expect(v.to_param).to eq(v.public_id)
  end
end
