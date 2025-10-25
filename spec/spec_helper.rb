# spec/spec_helper.rb
require "devise"
RSpec.configure do |config|
  config.example_status_persistence_file_path = "tmp/rspec-failures.txt"
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  # config.include Devise::Test::IntegrationHelpers, type: :request
end
