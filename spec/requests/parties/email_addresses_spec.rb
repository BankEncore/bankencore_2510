require "rails_helper"

RSpec.describe "Party EmailAddresses", type: :request do
  include_context "as_admin"
  let(:user) { create(:user, :system_admin, :confirmed) }

  let(:party) { create(:party) }

  it "creates" do
    post party_email_addresses_path(party),
         params: { parties_email_address: { email: "a@b.co", preferred: true } }
    expect(response).to redirect_to(party_path(party))
  end

  it "rejects bad email" do
    post party_email_addresses_path(party),
         params: { parties_email_address: { email: "bad" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "enforces single preferred" do
    create(:parties_email_address, party:, email: "x@x.co", preferred: true)
    post party_email_addresses_path(party),
         params: { parties_email_address: { email: "y@y.co", preferred: true } }
    expect(response).to redirect_to(party_path(party))
  end
end
