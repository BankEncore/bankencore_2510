# spec/requests/payments/ach_routings_spec.rb
require "rails_helper"

RSpec.describe "Payments::AchRoutings", type: :request do
  it "indexes with search and pagination params" do
    create_list(:payments_ach_routing, 3, customer_name: "PNC")
    get payments_ach_routings_path, params: { q: "PNC", items: 2 }
    expect(response).to have_http_status(:ok)
  end

  it "shows a routing" do
    r = create(:payments_ach_routing)
    get payments_ach_routing_path(r.public_id)
    expect(response).to have_http_status(:ok)
  end
end
