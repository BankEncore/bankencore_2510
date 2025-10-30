# spec/requests/parties/web_addresses_spec.rb
require "rails_helper"

RSpec.describe "Party WebAddresses", type: :request do
  include_context "as_admin"
  let(:user)  { login }
  let(:party) { create(:party) }

  it "creates and normalizes" do
    post party_web_addresses_path(party), params: { parties_web_address: { url: "example.com", preferred: true } }
    expect(response).to redirect_to(party_path(party))
    expect(party.web_addresses.last.url).to match(%r{\Ahttps?://})
  end

  it "rejects bad url" do
    post party_web_addresses_path(party), params: { parties_web_address: { url: "not a url" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "enforces single preferred" do
    create(:parties_web_address, party:, url: "https://x.test", preferred: true)
    post party_web_addresses_path(party), params: { parties_web_address: { url: "https://y.test", preferred: true } }
    expect(response).to redirect_to(party_path(party))
    expect(flash[:alert]).to match(/Only one preferred/i)
  end
end
