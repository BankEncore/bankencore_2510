# spec/policies/application_policy_spec.rb
require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:user) { build(:user) }
  let(:record) { Object.new }
  subject(:policy) { described_class.new(user, record) }

  it { expect(policy.index?).to be false }
  it { expect(policy.show?).to be false }
  it { expect(policy.create?).to be false }
  it { expect(policy.update?).to be false }
  it { expect(policy.destroy?).to be false }
end
