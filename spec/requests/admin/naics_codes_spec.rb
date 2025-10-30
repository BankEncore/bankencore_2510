# spec/requests/admin/naics_codes_spec.rb
require "rails_helper"

RSpec.describe "Admin::System::NaicsCodes", type: :request do
  let(:user) { create(:user, :system_admin) } # has sysadmin role/permissions

  before { sign_in user }

  it "index ok" do
    create(:system_naics_code, version: "2022")
    get admin_system_naics_codes_path(version: "2022")
    expect(response).to have_http_status(:ok)
  end

  it "show ok" do
    code = create(:system_naics_code, code: "11", version: "2022")
    get admin_system_naics_code_path(code: code.code, version: "2022")
    expect(response).to have_http_status(:ok)
  end
end
