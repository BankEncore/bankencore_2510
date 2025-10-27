# spec/requests/parties/names_spec.rb
require "rails_helper"

RSpec.describe "Party Names", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :system_admin) }
  let(:party) { create(:party) }

  before { sign_in admin }

  it "creates a name for a party" do
    post "/parties/#{party.id}/names.json", params: {
      parties_name: { name_type_code: "legal", full_name: "Alice B Example", preferred: true }
    }
    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body["full_name"]).to eq("Alice B Example")
  end

  it "lists names for a party" do
    create(:parties_name, party:)
    get "/parties/#{party.id}/names.json"
    expect(response).to have_http_status(:ok)
    arr = JSON.parse(response.body)
    expect(arr).to be_an(Array)
    expect(arr.first["party_id"]).to eq(party.id)
  end
end
