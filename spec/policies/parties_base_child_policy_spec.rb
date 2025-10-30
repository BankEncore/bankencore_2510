# spec/policies/parties_base_child_policy_spec.rb
require "rails_helper"

RSpec.describe Parties::BaseChildPolicy do
  let(:party) { create(:party) }
  let(:name)  { build(:parties_name, party: party) }

  it "inherits Party permissions" do
    user = build(:user, :system_admin)

    base = described_class.new(user, name)
    party_pol = Parties::PartyPolicy.new(user, party)

    expect(base.show?).to eq(party_pol.show?)
    expect(base.update?).to eq(party_pol.update?)
  end
end
