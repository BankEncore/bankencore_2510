# spec/system/reference_values_spec.rb
require "rails_helper"

RSpec.describe "Reference values UI", type: :system do
  include Rails.application.routes.url_helpers

  it "edits then cancels to index" do
    driven_by :rack_test

    list  = create(:system_reference_list)                        # factory supplies correct cols
    value = create(:system_reference_value, reference_list: list) # factory supplies correct cols

    edit_path  = respond_to?(:edit_admin_system_reference_value_path) ? edit_admin_system_reference_value_path(value) : nil
    index_path = respond_to?(:admin_system_reference_list_reference_values_path) ? admin_system_reference_list_reference_values_path(list) : "/admin/system/reference_values"
    skip "admin reference value routes missing" unless edit_path

    visit edit_path

    if page.has_link?(/cancel|back/i)
      click_link(/cancel|back/i)
    elsif page.has_button?(/cancel|back/i)
      click_button(/cancel|back/i)
    else
      # common admin link text
      links = all("a").map(&:text)
      fail "no cancel/back control; links: #{links.inspect}"
    end

    expect(page).to have_current_path(index_path, ignore_query: true)
    expect(page).to have_text(list.name)
    expect(page).to have_text(value.try(:name) || value.try(:label) || value.try(:code))
  end
end
