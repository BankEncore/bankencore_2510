# spec/requests/parties/phones_spec.rb
require "rails_helper"

RSpec.describe "Party Phones", type: :request do
  include_context "as_admin"
  let(:user)  { login }
  let(:party) { create(:party) }

  it "creates" do
    post party_phones_path(party), params: { parties_phone: { phone_type_code: "mobile", e164: "+14155550123", preferred: true } }
    expect(response).to redirect_to(party_path(party))
    expect(party.phones.count).to eq(1)
  end

  it "rejects bad e164" do
    post party_phones_path(party), params: { parties_phone: { e164: "415-555-0123" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "enforces single preferred" do
    create(:parties_phone, party:, e164: "+14155550000", preferred: true)
    post party_phones_path(party), params: { parties_phone: { e164: "+14155550001", preferred: true } }
    expect(response).to redirect_to(party_path(party))
    expect(flash[:alert]).to match(/Only one preferred/i)
  end
end
