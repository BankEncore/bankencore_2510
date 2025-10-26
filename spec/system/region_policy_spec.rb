require "rails_helper"

RSpec.describe System::RegionPolicy do
  subject(:policy) { described_class.new(user, record) }
  let(:record) { build(:system_region) }

  context "system admin" do
    let(:user) { create(:user, :adminish) }
    it { is_expected.to permit_actions(%i[index show]) } # writes not exposed in this policy
  end

  context "normal user" do
    let(:user) { create(:user) }
    it { is_expected.to permit_actions(%i[index show]) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end
end
