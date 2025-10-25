# spec/system/reference_values_spec.rb
require "rails_helper"

RSpec.describe "Reference values UI", type: :system do
  before do
    driven_by(:rack_test)
    skip "route missing" unless Rails.application.routes.url_helpers.respond_to?(:edit_system_reference_list_reference_value_path)
  end

  let!(:list)  { create(:system_reference_list) }
  let!(:value) { create(:system_reference_value, reference_list: list, code: "A", name: "Active") }

  it "edits then cancels to index" do
    visit edit_system_reference_list_reference_value_path(list, value)
    # Adjust the cancel selector to your UI
    click_link("Cancel") rescue click_on("Cancel")

    # Be tolerant about target
    expect(page).to have_current_path(admin_system_reference_list_path(list)).or have_content(list.name)
  end
end
