require 'rails_helper'

RSpec.describe "Parties::TaxIds", type: :request do
  include Devise::Test::IntegrationHelpers
  let(:user) { create(:user, :system_admin) }
  before { sign_in user }

  let(:party)  { create(:parties_party) }
  let(:tax_id) { create(:parties_tax_id, party:) }

  describe "GET /index" do
    it "returns http success" do
      get party_tax_ids_path(party)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_party_tax_id_path(party)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_party_tax_id_path(party, tax_id)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get party_tax_id_path(party, tax_id)
      expect(response).to have_http_status(:success)
    end
  end
end
