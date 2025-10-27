# spec/requests/parties/parties_spec.rb
require "rails_helper"

RSpec.describe "Parties", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :system_admin) }

  before { sign_in admin }

  describe "GET /parties" do
    it "lists parties" do
      create(:party)
      get "/parties.json"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["items"].length).to be >= 1
    end
  end

  describe "POST /parties" do
    it "creates a party" do
      post "/parties.json", params: {
        party: { relationship_to_institution_code: "customer" }
      }
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["relationship_to_institution_code"]).to eq("customer")
    end
  end

  describe "GET /parties/:id" do
    it "shows a party" do
      party = create(:party)
      get "/parties/#{party.id}.json"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(party.id)
    end
  end
end
