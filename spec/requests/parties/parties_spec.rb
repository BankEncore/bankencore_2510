# spec/requests/parties/parties_spec.rb
require "rails_helper"

RSpec.describe "Parties index", type: :request do
  let(:user) { create(:user, :system_admin) }

  before { sign_in user }

  it "lists" do
    create(:party) # or :parties_party if factory namespaced
    get parties_path
    expect(response).to have_http_status(:ok)
  end
end
