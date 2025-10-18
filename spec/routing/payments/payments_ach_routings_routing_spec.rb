# spec/system/payments/ach_routings_crud_spec.rb
require "rails_helper"

RSpec.describe "ACH Routings UI", type: :system do
  it "creates a routing via form" do
    visit new_payments_ach_routing_path
    fill_in "Routing number", with: "071000301"
    fill_in "Institution name", with: "FRB Chicago Test"
    fill_in "City", with: "Chicago"
    select "IL", from: "State"

    # select by value (RTN)
    find("select[name='payments_ach_routing[servicing_frb_number]'] option[value='071000301']").select_option

    check "Federal Reserve Bank"
    click_button "Create Ach routing"

    expect(page).to have_content("FRB Chicago Test")
    expect(page).to have_content("FRB: Chicago")
  end
end
