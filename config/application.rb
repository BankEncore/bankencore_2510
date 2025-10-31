require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bankencore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.active_record.schema_format = :sql

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # config/application.rb
    config.time_zone = "Eastern Time (US & Canada)"
    config.active_record.default_timezone = :utc
    # config.eager_load_paths << Rails.root.join("app/lib")
    config.paths.add "app/lib", eager_load: true
    config.autoload_paths  << Rails.root.join("app/lib")
    config.eager_load_paths << Rails.root.join("app/lib")
    config.autoload_paths  << Rails.root.join("app/policies")
    config.eager_load_paths << Rails.root.join("app/policies")

    config.active_record.encryption.primary_key = ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"]
    config.active_record.encryption.deterministic_key = ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"]
    config.active_record.encryption.key_derivation_salt = ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"]
    config.active_record.encryption.support_unencrypted_data = true
  end
end
