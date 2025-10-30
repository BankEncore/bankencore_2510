# spec/rails_helper.rb
ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "factory_bot_rails"   # ← add
require "devise"              # optional but harmless
require "pundit/rspec"

# Maintain test schema
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# Load support files
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # Devise helpers
  config.include Devise::Test::IntegrationHelpers, type: :request
  # config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::ControllerHelpers,  type: :controller
  config.include Devise::Test::ControllerHelpers,  type: :view
  config.include Pundit::RSpec::Matchers

  config.include Warden::Test::Helpers, type: :request

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.before(:each, type: :system) { driven_by :rack_test }
end

# Shoulda Matchers
Shoulda::Matchers.configure do |c|
  c.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.describe "System NAICS routing", type: :routing do
  it { expect(get: "/system/naics/2022").to route_to("system/naics_codes#index", version: "2022") }
  it { expect(get: "/system/naics/2022/311").to route_to("system/naics_codes#show", version: "2022", code: "311") }
end
