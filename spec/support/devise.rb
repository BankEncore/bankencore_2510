# spec/support/devise.rb
require "devise"
require "warden"

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers,  type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
end
