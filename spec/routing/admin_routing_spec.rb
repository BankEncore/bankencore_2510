# spec/routing/admin_routing_spec.rb
require "rails_helper"

RSpec.describe "Admin routing", type: :routing do
  it { expect(get: "/admin").to route_to("admin/dashboard#index") }
end
