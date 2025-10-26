# spec/system/ach_routings_crud_spec.rb
require "rails_helper"

RSpec.describe "ACH Routings UI", type: :system do
  let(:user) { create(:user, :adminish, :confirmed, password: "ChangeMe123!") }

  it "creates a routing via form" do
    driven_by :rack_test

    # Login via UI
    visit "/users/sign_in"
    find("form[action='/users/sign_in']")
    fill_in "user[email]",    with: user.email
    fill_in "user[password]", with: "ChangeMe123!"
    first("form[action='/users/sign_in'] input[type='submit'], form[action='/users/sign_in'] button[type='submit']").click

    # New ACH routing
    visit "/admin/payments/ach_routings/new"
    form = find("form[action='/admin/payments/ach_routings']")

    form.fill_in "payments_ach_routing_routing_number", with: "031000053"
    form.fill_in "payments_ach_routing_customer_name",  with: "PNC BANK, NA"
    form.fill_in "payments_ach_routing_address",        with: "1 PNC Plaza"
    form.fill_in "payments_ach_routing_city",           with: "PITTSBURGH"
    form.select  "PA",                                  from: "payments_ach_routing_state_code"
    form.fill_in "payments_ach_routing_zip_code",       with: "15222"
    form.fill_in "payments_ach_routing_phone_number",   with: "4125550000"
    form.select  "031000040",                           from: "payments_ach_routing_servicing_frb_number"
    form.first("input[type='submit'],button[type='submit']").click

    expect(page).to have_text("PNC BANK, NA")
    expect(page).to have_text("031000053")
  end
end
