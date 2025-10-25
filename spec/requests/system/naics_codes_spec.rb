# spec/requests/system/naics_codes_spec.rb
require "rails_helper"

RSpec.describe "System::NaicsCodes", type: :request do
  let(:version) { "2022" }

  it "lists with filters" do
    create(:system_naics_code, version:, code: "311", title: "Food", level: 3)
    get system_naics_version_path(version:)
    expect(response).to have_http_status(:ok)
  end

  it "shows a code" do
    n = create(:system_naics_code, version:, code: "311", title: "Food", level: 3)
    get system_naics_code_path(version: n.version, code: n.code)
    expect(response).to have_http_status(:ok)
  end
end
