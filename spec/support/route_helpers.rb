# spec/support/route_helpers.rb
module RouteHelpers
  def route_helper?(name)
    Rails.application.routes.url_helpers.respond_to?(name.to_sym)
  end
end

RSpec.configure { |c| c.include RouteHelpers }
