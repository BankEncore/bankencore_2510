# db/migrate/20251028020000_add_unvalidated_checks_for_parties.rb
class AddUnvalidatedChecksForParties < ActiveRecord::Migration[8.0]
  TARGETS = %i[
    names phones email_addresses postal_addresses web_addresses
    tax_ids identities disclosures secret_data consents communication_preferences
  ].freeze

  def up
    TARGETS.each do |t|
      tbl = :"parties_#{t}"
      next unless table_exists?(tbl)

      if column_exists?(tbl, :party_id)
      add_check_constraint tbl, "party_id IS NOT NULL",
                          name: chk_null(tbl), validate: false unless check_constraint_exists?(tbl, name: chk_null(tbl))
      end

      if column_exists?(tbl, :valid_from) && column_exists?(tbl, :valid_to)
      expr = "(valid_from IS NULL OR valid_to IS NULL OR valid_from <= valid_to)"
      add_check_constraint tbl, expr,
                          name: chk_range(tbl), validate: false unless check_constraint_exists?(tbl, name: chk_range(tbl))
      end
    end
  end

  def down
    TARGETS.each do |t|
      tbl = :"parties_#{t}"
      next unless table_exists?(tbl)
      remove_check_constraint tbl, name: chk_null(tbl)  if check_constraint_exists?(tbl, name: chk_null(tbl))
      remove_check_constraint tbl, name: chk_range(tbl) if check_constraint_exists?(tbl, name: chk_range(tbl))
    end
  end

  private

  def chk_null(tbl)  = "chk_#{tbl}_party_id_not_null"
  def chk_range(tbl) = "chk_#{tbl}_valid_range"
end
