# spec/models/branch_membership_spec.rb
# new
require "rails_helper"

RSpec.describe BranchMembership, type: :model do
  let(:user)   { create(:user) }
  let(:branch) { create(:branch) }

  it "is valid with user and branch" do
    bm = build(:branch_membership, user: user, branch: branch)
    expect(bm).to be_valid
  end

  it "enforces uniqueness of [user, branch]" do
    create(:branch_membership, user: user, branch: branch)
    dup = build(:branch_membership, user: user, branch: branch)
    expect(dup).not_to be_valid
    expect(dup.errors[:branch_id]).to be_present
  end

  it "scopes by user and branch" do
    a = create(:branch_membership, user: user, branch: branch)
    expect(BranchMembership.for_user(user)).to include(a)
    expect(BranchMembership.for_branch(branch)).to include(a)
  end

  it "delegates branch_name and branch_code" do
    bm = create(:branch_membership, user: user, branch: branch)
    expect(bm.branch_name).to eq(branch.name)
    expect(bm.branch_code).to eq(branch.code)
  end
end
