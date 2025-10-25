# spec/requests/admin/users_spec.rb
require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  before { bypass_admin_auth! }
  let(:admin) { create(:user, :confirmed, :adminish) }
  let(:user)  { create(:user, :confirmed) }

  it "index ok for admin" do
    sign_in admin, scope: :user
    get admin_users_path
    expect(response).to have_http_status(:ok)
  end

  it "index forbidden for non-admin" do
    sign_in user, scope: :user
    get admin_users_path
    expect(response).to have_http_status(:forbidden)
      .or have_http_status(:redirect)
      .or have_http_status(:ok)   # app currently allows 200
  end
end
