# config/environments/development.rb

require "active_support/core_ext/integer/time"
require "socket"

# Resolve a sensible host for links in emails and redirects during development.
# Prefers APP_HOST; otherwise falls back to your machine's private LAN IP.
def local_ip
  Socket.ip_address_list.find(&:ipv4_private?)&.ip_address || "localhost"
end

Rails.application.configure do
  # ── Host/Port/Protocol for URL helpers and mailers ────────────────────────────
  host     = (ENV["APP_HOST"].presence || local_ip)
  port     = (ENV["APP_PORT"].presence || ENV["PORT"].presence || "3000")
  protocol = (ENV["APP_PROTOCOL"].presence || "http")

  # Settings here take precedence over config/application.rb.
  # ── Code loading and errors ───────────────────────────────────────────────────
  config.enable_reloading = true              # Hot reload without server restart
  config.eager_load = false                   # Faster boot in dev
  config.consider_all_requests_local = true   # Full error reports
  config.server_timing = true

  # ── Caching ──────────────────────────────────────────────────────────────────
  # Toggle with: bin/rails dev:cache  (creates tmp/caching-dev.txt)
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = {
      "cache-control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end
  config.cache_store = :memory_store          # Change to :null_store to disable

  # ── Active Storage ───────────────────────────────────────────────────────────
  config.active_storage.service = :local

  # ── Action Mailer ────────────────────────────────────────────────────────────
  # Use Letter Opener UI and generate correct absolute URLs in emails.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.default_url_options = { host:, port:, protocol: }
  config.action_mailer.asset_host = "#{protocol}://#{host}:#{port}"

  # ── Active Support / Active Record / Active Job ──────────────────────────────
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_record.query_log_tags_enabled = true
  config.active_job.verbose_enqueue_logs = true

  # ── I18n / Views / Cable / Callbacks / Generators ────────────────────────────
  # config.i18n.raise_on_missing_translations = true
  config.action_view.annotate_rendered_view_with_filenames = true
  # config.action_cable.disable_request_forgery_protection = true
  config.action_controller.raise_on_missing_callback_actions = true
  # config.generators.apply_rubocop_autocorrect_after_generate!
end
