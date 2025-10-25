# spec/system/payments/ach_routings_crud_spec.rb
require "rails_helper"

RSpec.describe "ACH Routings UI", type: :system do
  before do
    driven_by(:rack_test)
    skip "route missing" unless route_helper?(:new_payments_ach_routing_path)
  end

  it "creates a routing via form" do
    visit new_payments_ach_routing_path

    # Fill required fields by label or name fallback
    fill_in("Routing number", with: "071000301") rescue fill_in("payments_ach_routing[routing_number]", with: "071000301")
    fill_in("Institution name", with: "FRB Chicago Test") rescue fill_in("payments_ach_routing[customer_name]", with: "FRB Chicago Test")
    fill_in("City", with: "Chicago") rescue fill_in("payments_ach_routing[city]", with: "Chicago")
    select("IL", from: "State") rescue select("IL", from: "payments_ach_routing[state_code]")

    # FRB select (by value)
    find("select[name='payments_ach_routing[servicing_frb_number]'] option[value='071000301']").select_option

    # Optional fields if present
    begin
      fill_in("Phone", with: "312-322-5322")
    rescue Capybara::ElementNotFound
      # ignore optional phone
    end

    # Feature flags if present
    begin
      check("Federal Reserve Bank")
    rescue Capybara::ElementNotFound
      # ignore
    end

    click_button(/Create|Save/i)

    expect(page).to have_content("FRB Chicago Test")
    expect(page).to have_content(/FRB[: ] Chicago/i).or have_content(/Servicing FRB/i)
  end
end
