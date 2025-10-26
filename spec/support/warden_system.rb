# frozen_string_literal: true
require "warden"
require "warden/test/helpers"

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :system
  config.before(:each, type: :system) { Warden.test_mode! }
  config.after(:each,  type: :system) { Warden.test_reset! }
end
