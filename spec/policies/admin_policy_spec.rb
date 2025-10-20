# spec/policies/admin_policy_spec.rb
require "rails_helper"

RSpec.describe AdminPolicy do
  subject { described_class }

  it "denies non-admins" do
    policy = subject.new(build(:user, :confirmed, role_i: :read_only), :admin)
    expect(policy.access?).to be false
  end

  it "allows system_admin" do
    policy = subject.new(build(:user, :confirmed, role_i: :system_admin), :admin)
    expect(policy.access?).to be true
  end
end
