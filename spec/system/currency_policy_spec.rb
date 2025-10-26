require "rails_helper"

RSpec.describe System::CurrencyPolicy do
  subject(:policy) { described_class.new(user, record) }
  let(:record) { build(:system_currency) }

  context "any authenticated user" do
    let(:user) { create(:user) }
    it { is_expected.to permit_actions(%i[index show]) }
    it { is_expected.to forbid_actions(%i[new create edit update destroy]) }
  end
end
