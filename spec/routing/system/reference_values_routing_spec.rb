require "rails_helper"
RSpec.describe System::ReferenceValuesController, type: :routing do
  it "routes nested paths" do
    expect(get: "/system/reference_lists/abc/reference_values").
      to route_to("system/reference_values#index", reference_list_public_id: "abc")
    expect(get: "/system/reference_lists/abc/reference_values/def/edit").
      to route_to("system/reference_values#edit", reference_list_public_id: "abc", public_id: "def")
  end
end
