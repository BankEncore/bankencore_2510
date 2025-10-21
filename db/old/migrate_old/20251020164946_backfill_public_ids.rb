# db/migrate/20251020164946_backfill_public_ids.rb
class BackfillPublicIds < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  TABLES = %w[
    system_reference_lists
    system_reference_values
    system_naics_codes
    system_country_currencies
  ].freeze

  def up
    TABLES.each do |table|
      klass = Class.new(ActiveRecord::Base) { self.table_name = table }

      say_with_time "Backfilling #{table}.public_id" do
        loop do
          ids = klass.where(public_id: nil).order(:id).limit(10_000).pluck(:id)
          break if ids.empty?
          klass.where(id: ids).update_all('public_id = gen_random_uuid()')
          sleep 0.01
        end
      end
    end
  end
end
