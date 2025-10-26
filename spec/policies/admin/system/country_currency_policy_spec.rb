# spec/policies/admin/system/country_currency_policy_spec.rb
require "rails_helper"

RSpec.describe Admin::System::CountryCurrencyPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }
  let(:record) { System::CountryCurrency.new(country_alpha2: "US", currency_code: "USD") }

  context "as system admin" do
    let(:user) { create(:user, :adminish) }
    it { is_expected.to permit_actions(%i[index show new create edit update destroy]) }
  end

  context "as regular user" do
    let(:user) { create(:user) }
    it { is_expected.to forbid_actions(%i[index show new create edit update destroy]) }
  end
end
