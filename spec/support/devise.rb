# spec/support/devise.rb
# frozen_string_literal: true
require "devise"
# require "warden"
# require "warden/test/helpers"

RSpec.configure do |config|
  # Correct scoping
  config.include Devise::Test::ControllerHelpers,  type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # System specs use Warden helpers
  config.include Warden::Test::Helpers, type: :system
  # config.before(:each, type: :system) { Warden.test_mode! }
  # config.after(:each,  type: :system) { Warden.test_reset! }

  # Safety: only reset if helpers are loaded and method exists
  config.before(:each) do |ex|
    next if %i[request system controller].include?(ex.metadata[:type])
  #  Warden.test_reset! if defined?(Warden) && Warden.respond_to?(:test_reset!)
  end
end
