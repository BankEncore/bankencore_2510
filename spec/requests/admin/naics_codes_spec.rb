# spec/requests/admin/naics_codes_spec.rb
require "rails_helper"

RSpec.describe "Admin::System::NaicsCodes", type: :request do
  let(:admin)   { create(:user, :confirmed, :system_admin) }
  let(:version) { "2022" }

  before do
    bypass_admin_auth!
    sign_in admin, scope: :user
  end

  it "index ok" do
    get admin_system_naics_codes_path(version: version)
    expect(response).to have_http_status(:ok)
  end

  it "show ok" do
    n = create(:system_naics_code, version: version, code: "311", title: "Food", level: 3)
    get admin_system_naics_code_path(version: n.version, code: n.code)
    expect(response).to have_http_status(:ok)
  end
end
