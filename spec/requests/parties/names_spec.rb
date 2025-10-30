# spec/requests/parties/names_spec.rb
require "rails_helper"

RSpec.describe "Party Names", type: :request do
  include_context "as_admin"

  let(:party) { create(:party) }

  it "creates preferred and points party" do
    post party_names_path(party),
         params: { parties_name: { name_type_code: "legal", full_name: "Acme", preferred: true } }
    expect(response).to redirect_to(party_path(party))
    expect(party.reload.preferred_party_name_id).to be_present
  end

  it "enforces single preferred" do
    create(:parties_name, party: party, name_type_code: "legal", full_name: "One", preferred: true)
    post party_names_path(party),
         params: { parties_name: { name_type_code: "aka", full_name: "Two", preferred: true } }
    expect(response).to redirect_to(party_path(party))
    expect(flash[:alert]).to match(/Only one preferred/i)
  end
end
