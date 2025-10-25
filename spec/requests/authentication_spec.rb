# spec/requests/admin/users_spec.rb
require "rails_helper"

RSpec.describe "Authentication", type: :request do
  it "allows confirmed admin to /admin" do
    bypass_admin_auth!
    admin = create(:user, :confirmed, :adminish)
    sign_in admin, scope: :user
    get admin_root_path
    expect(response).to have_http_status(:ok)
  end
end
