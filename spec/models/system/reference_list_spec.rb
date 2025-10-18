require "rails_helper"

RSpec.describe System::ReferenceList, type: :model do
  it { is_expected.to have_many(:reference_values).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }
  it "uses public_id for to_param" do
    list = build(:system_reference_list)
    expect(list.to_param).to eq(list.public_id)
  end
end
