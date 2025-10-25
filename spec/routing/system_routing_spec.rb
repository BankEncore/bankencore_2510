# spec/routing/system_routing_spec.rb
require "rails_helper"

RSpec.describe "System NAICS routing", type: :routing do
  it { expect(get: "/system/naics/2022").to route_to("system/naics_codes#index", version: "2022") }
  it { expect(get: "/system/naics/2022/311").to route_to("system/naics_codes#show", version: "2022", code: "311") }
end
