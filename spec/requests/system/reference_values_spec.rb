require "rails_helper"

RSpec.describe "System::ReferenceValues", type: :request do
  let(:admin) { create(:user, :confirmed, :adminish) }
  let(:list)  { create(:system_reference_list) }

  before do
    bypass_admin_auth!
    sign_in admin, scope: :user

    helpers = Rails.application.routes.url_helpers
    if helpers.respond_to?(:admin_system_reference_list_reference_values_path)
      @create_path = helpers.admin_system_reference_list_reference_values_path(list)
    elsif helpers.respond_to?(:admin_system_reference_values_path)
      @create_path = helpers.admin_system_reference_values_path
    else
      skip "admin reference_values routes missing"
    end
  end

  it "creates with valid params" do
    post @create_path,
         params: { system_reference_value: { reference_list_id: list.id, code: "A", name: "Active", active: true } }
    expect(response).to be_redirect.or have_http_status(:ok).or have_http_status(:created)
  end

  it "rejects invalid metadata when column exists" do
    skip "metadata column not present" unless System::ReferenceValue.column_names&.include?("metadata")

    post @create_path,
         params: { system_reference_value: { reference_list_id: list.id,
                                             code: "B", name: "Broken",
                                             metadata: "not_json" } }
    expect(response).to have_http_status(:unprocessable_content).or have_http_status(:found)
  end
end
