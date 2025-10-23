# spec/models/permission_spec.rb
# new
require "rails_helper"

RSpec.describe Permission, type: :model do
  it "enforces unique key" do
    create(:permission, :admin_access)
    expect(build(:permission, :admin_access)).to be_invalid
  end
end
