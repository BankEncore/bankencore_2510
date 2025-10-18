# spec/rails_helper.rb
ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

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

  # Use transactional DB tests
  config.use_transactional_fixtures = true

  # Infer spec type from file location (models, requests, etc.)
  config.infer_spec_type_from_file_location!

  # Cleaner backtraces
  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name") # add as needed
end

# Shoulda Matchers
Shoulda::Matchers.configure do |c|
  c.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
