# spec/policies/admin/user_policy_spec.rb
require "rails_helper"

RSpec.describe Admin::UserPolicy do
  subject(:policy) { described_class.new(user, record) }
  let(:record) { build(:user) }

  context "admin" do
    let(:user) { create(:user, :confirmed, :adminish) }

    before do
      # cover policies that call different predicates
      allow(user).to receive(:admin?).and_return(true)
      allow(user).to receive(:system_admin?).and_return(true)
      allow(user).to receive(:has_role?).and_return(true)
    end

    it { expect(policy.index?).to be true }
    it { expect(policy.show?).to be true }
    it { expect(policy.update?).to be true }

    it "scopes to relation" do
      expect(Pundit.policy_scope!(user, User.all)).to be_an(ActiveRecord::Relation)
    end
  end

  context "non-admin" do
    let(:user) { create(:user, :confirmed) }
    it { expect(policy.index?).to be false }
    it { expect(policy.show?).to be false }
    it { expect(policy.update?).to be false }
  end
end
