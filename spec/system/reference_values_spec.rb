# spec/system/reference_values_spec.rb
require "rails_helper"

RSpec.describe "Reference values UI", type: :system do
  before { driven_by :rack_test }   # <— forces non-Selenium driver

  let!(:list)  { create(:system_reference_list) }
  let!(:value) { create(:system_reference_value, reference_list: list) }

  it "edits then cancels to index" do
    visit edit_system_reference_list_reference_value_path(list, value)
    click_link "Cancel"
    expect(page).to have_current_path(system_reference_list_reference_values_path(list), ignore_query: true)
  end
end
