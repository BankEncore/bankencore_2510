# spec/policies/system/naics_code_policy_spec.rb
require "rails_helper"

RSpec.describe System::NaicsCodePolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }
  let(:record) { build(:system_naics_code) }

  context "admin" do
    let(:user) { create(:user, :adminish) }
    it { is_expected.to permit_actions(%i[index show]) }
    it { is_expected.to forbid_actions(%i[new create edit update destroy]) }
  end

  context "regular user" do
    let(:user) { create(:user) }
    it { is_expected.to permit_actions(%i[index show]) }
    it { is_expected.to forbid_actions(%i[new create edit update destroy]) }
  end
end
