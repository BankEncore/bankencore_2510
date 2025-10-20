# spec/support/devise.rb
require "devise"
require "warden"

RSpec.configure do |config|
  # config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Warden::Test::Helpers,           type: :request
  config.after(type: :request) { Warden.test_reset! }
end
