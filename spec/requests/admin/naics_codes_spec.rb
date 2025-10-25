# spec/requests/admin/naics_codes_spec.rb
require "rails_helper"

RSpec.describe "Admin::System::NaicsCodes", type: :request do
  let(:admin)   { create(:user, :confirmed, :adminish) }
  let(:version) { "2022" }

  it "index ok" do
    bypass_admin_auth!
    sign_in admin, scope: :user
    get admin_system_naics_codes_path(version:)
    expect(response).to have_http_status(:ok)
  end

  it "show ok" do
    bypass_admin_auth!
    sign_in admin, scope: :user
    n = create(:system_naics_code, version:, code: "311", title: "Food", level: 3)
    get admin_system_naics_code_admin_path(version: n.version, code: n.code)
    expect(response).to have_http_status(:ok)
  end
end
