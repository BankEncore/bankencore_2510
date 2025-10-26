# spec/models/branch_membership_spec.rb
require "rails_helper"

RSpec.describe BranchMembership, type: :model do
  before { create(:system_country) } # alpha2: "US"

  let(:user)   { create(:user) }
  let(:branch) { create(:branch, :no_hours) } # persists, satisfies FKs
  subject(:membership) { build(:branch_membership, branch:, user:) }

  it { is_expected.to belong_to(:branch) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:branch) }
  it { is_expected.to validate_presence_of(:user) }

  it "prevents duplicate branch-user pairs" do
    create(:branch_membership, branch:, user:) # first row persisted
    expect(membership).not_to be_valid
    expect(membership.errors[:branch_id]).to include("has already been taken")
  end
end
