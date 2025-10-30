# spec/requests/parties/organizations_spec.rb
require "rails_helper"

RSpec.describe "Party Organization", type: :request do
  include_context "as_admin"
  let(:user)  { login }
  let(:party) { create(:party) }

  it "creates" do
    post party_organization_path(party), params: { organization: { residence_country: "US", organization_type_code: "corp" } }
    expect(response).to redirect_to(party_path(party))
    expect(party.reload.organization).to be_present
  end

  it "updates" do
    party.create_organization!(residence_country: "US")
    patch party_organization_path(party), params: { organization: { tax_exempt_code: "501c3" } }
    expect(response).to redirect_to(party_path(party))
    expect(party.organization.reload.tax_exempt_code).to eq("501c3")
  end

  it "destroys" do
    party.create_organization!(residence_country: "US")
    delete party_organization_path(party)
    expect(response).to redirect_to(party_path(party))
    expect(party.reload.organization).to be_nil
  end
end
