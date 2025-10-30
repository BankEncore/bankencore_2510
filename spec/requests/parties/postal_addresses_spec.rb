# spec/requests/parties/postal_addresses_spec.rb
require "rails_helper"

RSpec.describe "Party PostalAddresses", type: :request do
  include_context "as_admin"
  let(:user)  { login }
  let(:party) { create(:party) }

  it "creates" do
    post party_postal_addresses_path(party), params: { parties_postal_address: { line1: "1 Main", city: "PHL", country: "US", preferred: true } }
    expect(response).to redirect_to(party_path(party))
  end

  it "rejects bad window" do
    post party_postal_addresses_path(party), params: { parties_postal_address: { line1: "1 Main", valid_from: "2025-01-02", valid_to: "2025-01-01" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "enforces single preferred" do
    create(:parties_postal_address, party:, line1: "X", country: "US", preferred: true)
    post party_postal_addresses_path(party), params: { parties_postal_address: { line1: "Y", country: "US", preferred: true } }
    expect(response).to redirect_to(party_path(party))
    expect(flash[:alert]).to match(/Only one preferred/i)
  end
end
