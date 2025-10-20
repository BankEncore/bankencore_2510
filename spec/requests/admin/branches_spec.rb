# spec/requests/admin/branches_spec.rb
require "rails_helper"

RSpec.describe "Admin::Branches", type: :request do
  let(:admin) { create(:user, :confirmed, :system_admin) }
  before { login_as(admin, scope: :user) }

  it "creates, updates, and deletes a branch" do
    code = format("%03d", 100 + rand(900))
    expect {
      post admin_branches_path, params: { branch: { code:, name: "Test", status: "active" } }
    }.to change(Branch, :count).by(1)

    b = Branch.find_by!(code:)
    expect(response).to redirect_to(admin_branch_path(b))

    patch admin_branch_path(b), params: { branch: { name: "Test Updated" } }
    expect(b.reload.name).to eq("Test Updated")

    delete admin_branch_path(b)
    expect(response).to redirect_to(admin_branches_path)
    expect(Branch.exists?(b.id)).to be(false)
  end
end
