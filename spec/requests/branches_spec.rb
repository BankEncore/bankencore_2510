# spec/requests/branches_spec.rb
require "rails_helper"
RSpec.describe "Branches", type: :request do
  let!(:branch) { create(:branch, code: "001", name: "Main Office") }

  it "lists branches" do
    get branches_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Main Office")
  end

  it "shows a branch" do
    get branch_path(branch.public_id || branch.id)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("001")
  end
end
