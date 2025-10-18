# spec/requests/system/reference_values_spec.rb
require "rails_helper"

RSpec.describe "System::ReferenceValues", type: :request do
  let!(:list)  { create(:system_reference_list) }
  let!(:value) { create(:system_reference_value, reference_list: list) }

  it "shows index" do
    get system_reference_list_reference_values_path(list)
    expect(response).to have_http_status(:ok)
  end

  it "updates and redirects via polymorphic helper" do
    patch system_reference_list_reference_value_path(list, value),
          params: { reference_value: { label: "Updated" } }
    expect(response).to redirect_to([ list, value ])
    follow_redirect!
    expect(request.path).to eq(system_reference_list_reference_value_path(list, value))
    expect(response.body).to include("Updated")
  end

  it "creates and redirects to show" do
    post system_reference_list_reference_values_path(list),
         params: { reference_value: { key: "passport", label: "Passport" } }
    expect(response).to have_http_status(:found)
    follow_redirect!
    expect(request.path).to match(%r{\A/system/reference_lists/#{list.public_id}/reference_values/[^/]+\z})
    expect(response.body).to include("Passport")
  end
end
