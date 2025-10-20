# spec/policies/admin/branch_policy_spec.rb
require "rails_helper"
RSpec.describe Admin::BranchPolicy do
  subject(:policy) { described_class }
  let(:branch) { build(:branch) }

  it "allows admin" do
    user = build(:user, :admin)
    expect(policy).to permit(user, [ :admin, branch ])
  end

  it "denies non-admin" do
    user = build(:user)
    expect(policy).not_to permit(user, [ :admin, branch ])
  end
end
