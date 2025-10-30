# spec/support/reference_seeds.rb
RSpec.configure do |c|
  c.before(:suite) do
    # ---- countries required by FKs ----
    ActiveRecord::Base.connection.execute <<~SQL
      INSERT INTO system_countries (alpha2, alpha3, "numeric", iso_short_name, iso_long_name, created_at, updated_at)
      VALUES ('US','USA','840','United States','United States of America', NOW(), NOW())
      ON CONFLICT (alpha2) DO UPDATE
        SET iso_short_name = EXCLUDED.iso_short_name,
            iso_long_name  = EXCLUDED.iso_long_name,
            active         = TRUE,
            updated_at     = NOW();
    SQL

    # Optional minimal region, only if table exists
    if ActiveRecord::Base.connection.table_exists?("system_regions")
      ActiveRecord::Base.connection.execute <<~SQL
        INSERT INTO system_regions (country_alpha2, region_code, name, kind, iso_code, active, metadata, created_at, updated_at)
        SELECT 'US','US-XX','Test Region','state','US-XX', TRUE, '{}'::jsonb, NOW(), NOW()
        WHERE NOT EXISTS (
          SELECT 1 FROM system_regions WHERE country_alpha2='US' AND region_code='US-XX'
        );
      SQL
    end

    # ---- reference lists/values used by Parties ----
    lists = {
      "parties.relationship_to_institution" => %w[customer],
      "parties.name_types"                  => %w[legal aka],
      "parties.phone_types"                 => %w[mobile home work],
      "parties.address_types"               => %w[home work mailing],
      "parties.address_uses"                => %w[primary secondary],
      "parties.email_types"                 => %w[primary work personal],
      "parties.identity_types"              => %w[passport driver_license national_id],
      "parties.tax_id_types"                => %w[ein ssn tin itin],
      "parties.organization_types"          => %w[corp llc nonprofit],
      "parties.tax_exempt_codes"            => %w[501c3 501c6 none]
    }

    lists.each do |key, codes|
      list = System::ReferenceList.find_or_create_by!(key:) { |l| l.name = key.tr(".", " ").humanize }
      codes.each do |code|
        System::ReferenceValue.find_or_create_by!(reference_list_id: list.id, code:) { |rv| rv.name = code.humanize }
      end
    end
  end
end
