# spec/policies/admin_access_spec.rb
require "rails_helper"

RSpec.describe AdminPolicy do
  it "denies non-admins" do
    user = build(:user, :confirmed, role_i: :staff)
    expect(described_class.new(user, :admin).access?).to be false
  end

  it "allows system_admin" do
    user = build(:user, :confirmed, role_i: :system_admin)
    expect(described_class.new(user, :admin).access?).to be true
  end
end
