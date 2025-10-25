# spec/models/role_spec.rb
# new
require "rails_helper"

RSpec.describe Role, type: :model do
  it "enforces unique key" do
    create(:role, :viewer)
    dup = build(:role, :viewer)
    expect(dup).to be_invalid
  end

  it "associates permissions" do
    r = create(:role, :staff)
    p = create(:permission, key: "branches.write", name: "Branches write")
    create(:role_permission, role: r, permission: p)
    expect(r.permissions.pluck(:key)).to include("branches.write")
  end
end
