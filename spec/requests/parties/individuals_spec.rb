# spec/requests/parties/individuals_spec.rb
require "rails_helper"

RSpec.describe "Party Individual", type: :request do
  include_context "as_admin"

  let(:user)  { login }
  let(:party) { create(:party) }

  it "creates" do
    post party_individual_path(party), params: { individual: { residence_country: "US", gender_code: "m" } }
    expect(response).to redirect_to(party_path(party))
    expect(party.reload.individual).to be_present
  end

  it "updates" do
    party.create_individual!(residence_country: "US")
    patch party_individual_path(party), params: { individual: { occupation_code: "eng" } }
    expect(response).to redirect_to(party_path(party))
    expect(party.individual.reload.occupation_code).to eq("eng")
  end

  it "destroys" do
    party.create_individual!(residence_country: "US")
    delete party_individual_path(party)
    expect(response).to redirect_to(party_path(party))
    expect(party.reload.individual).to be_nil
  end
end
