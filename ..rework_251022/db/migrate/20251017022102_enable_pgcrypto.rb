# db/migrate/20251017022102_enable_pgcrypto.rb
# new
class EnablePgcrypto < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end
end
