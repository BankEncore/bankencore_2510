# spec/policies/admin/system/region_policy_spec.rb
RSpec.describe Admin::System::RegionPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }
  let(:record) { build(:system_region) }

  context "system admin" do
    let(:user) { create(:user, :adminish) }   # not :system_admin
    it { is_expected.to permit_actions(%i[index show new create edit update destroy]) }
  end

  context "normal user" do
    let(:user) { create(:user) }
    it { is_expected.to forbid_actions(%i[index show new create edit update destroy]) }
  end
end
