# spec/requests/parties/identities_spec.rb
require "rails_helper"

RSpec.describe "Party Identities", type: :request do
  include_context "as_admin"  # provides login_as(user, scope: :user)
  let(:user)  { login }
  let(:party) { create(:party) }

  it "creates passport" do
    post party_identities_path(party), params: { parties_identity: { identity_type_code: "passport", number: "x123", issuing_country: "US" } }
    expect(response).to redirect_to(party_path(party))
  end

  it "rejects bad date order" do
    post party_identities_path(party), params: { parties_identity: { identity_type_code: "driver_license", number: "a1", issued_on: "2025-01-02", expires_on: "2025-01-01" } }
    expect(response).to have_http_status(:unprocessable_content)
  end
end
