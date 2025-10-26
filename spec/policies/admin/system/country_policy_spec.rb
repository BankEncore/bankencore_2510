# spec/policies/admin/system/country_policy_spec.rb
require "rails_helper"

RSpec.describe Admin::System::CountryPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }
  let(:record) { build(:system_country) }

  context "system admin" do
    let(:user) { create(:user, :adminish) }
    it { is_expected.to permit_actions(%i[index show new create edit update destroy]) }
  end

  context "regular user" do
    let(:user) { create(:user) }
    it { is_expected.to forbid_actions(%i[index show new create edit update destroy]) }
  end
end
