# spec/requests/payments/ach_routings_spec.rb
require "rails_helper"

RSpec.describe "Payments::AchRoutings", type: :request do
  let!(:routing) { create(:payments_ach_routing) }

  it "GET /payments/ach_routings#index works" do
    get payments_ach_routings_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ACH Routings")
  end

  it "GET /payments/ach_routings/:public_id shows record" do
    get payments_ach_routing_path(routing)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(routing.customer_name)
  end

    it "POST /payments/ach_routings creates with normalized fields" do
    params = {
        payments_ach_routing: {
        routing_number: "518",                 # will pad to 000000518
        new_routing_number: "",                # will coerce to 000000000
        customer_name: "U.S. TREASURY",
        city: "ARLINGTON",
        state_code: "VA",
        servicing_frb_number: "031000040",     # already 9 digits
        phone_number: "7035551212",          # digits present to satisfy CHECK
        us_treasury: "1"
        }
    }

    post payments_ach_routings_path, params: params
    expect(response).to have_http_status(:found) # 302
    follow_redirect!
    expect(response).to have_http_status(:ok)

    created = Payments::AchRouting.order(:created_at).last
    expect(created.routing_number).to eq("000000518")
    expect(created.new_routing_number).to eq("000000000")
    expect(created.office_code).to eq("O")
    expect(created.us_treasury).to be(true)
    expect(created.phone_number).to eq("7035551212") # if you normalize digits
    end

  it "PATCH /payments/ach_routings/:public_id updates booleans and notes" do
    patch payments_ach_routing_path(routing), params: {
      payments_ach_routing: { on_us: "1", notes: "Test note" }
    }
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(routing.reload.on_us).to eq(true)
    expect(routing.notes).to eq("Test note")
  end
end
