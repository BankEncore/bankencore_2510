# db/migrate/20251028020100_validate_checks_and_enforce_not_null.rb
class ValidateChecksAndEnforceNotNull < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  TARGETS = %i[
    names phones email_addresses postal_addresses web_addresses
    tax_ids identities disclosures secret_data consents communication_preferences
  ].freeze

  def up
    TARGETS.each do |t|
      tbl = :"parties_#{t}"
      next unless table_exists?(tbl) && column_exists?(tbl, :party_id)

      # fail early if any nulls
      raise "#{tbl}: party_id has NULLs" if any_nulls?(tbl, :party_id)

      # validate NOT NULL helper check, then enforce NOT NULL, then remove helper check
      if check_constraint_exists?(tbl, name: chk_null(tbl))
        validate_check_constraint tbl, name: chk_null(tbl)
        change_column_null tbl, :party_id, false
        remove_check_constraint tbl, name: chk_null(tbl)
      end

      # validate date-range check if present
      validate_check_constraint tbl, name: chk_range(tbl) if check_constraint_exists?(tbl, name: chk_range(tbl))
    end
  end

  def down
    TARGETS.each do |t|
      tbl = :"parties_#{t}"
      next unless table_exists?(tbl) && column_exists?(tbl, :party_id)
      change_column_null tbl, :party_id, true rescue nil
      # keep validated range checks
    end
  end

  private

  def any_nulls?(table, col)
    connection.select_value("SELECT 1 FROM #{table} WHERE #{col} IS NULL LIMIT 1").present?
  end

  def chk_null(tbl)  = "chk_#{tbl}_party_id_not_null"
  def chk_range(tbl) = "chk_#{tbl}_valid_range"
end
