# spec/models/user_spec.rb
# new
require "rails_helper"

RSpec.describe User, type: :model do
  subject do
    build(:user, email: "user@example.com", first_name: "Ada", last_name: "Lovelace")
  end

  it "is valid with required fields" do
    expect(subject).to be_valid
  end

  it "builds display_name and full_name" do
    subject.validate
    expect(subject.display_name).to eq("Ada Lovelace")
    expect(subject.full_name).to eq("Ada Lovelace")
  end

  it "validates locale and phone formats" do
    subject.locale = "en-US"
    subject.phone_e164 = "+14125550123"
    expect(subject).to be_valid
    subject.locale = "english"
    expect(subject).to be_invalid
    subject.locale = "en-US"
    subject.phone_e164 = "412-555-0123"
    expect(subject).to be_invalid
  end

  describe "RBAC via permissions" do
    it "grants admin through role permission" do
      u = create(:user, :system_admin)
      expect(u.system_admin?).to eq(true)
      expect(u.can?("admin.access")).to eq(true)
    end

    it "viewer cannot admin" do
      u = create(:user, :viewer)
      expect(u.system_admin?).to eq(false)
      expect(u.can?("admin.access")).to eq(false)
    end
  end
end
