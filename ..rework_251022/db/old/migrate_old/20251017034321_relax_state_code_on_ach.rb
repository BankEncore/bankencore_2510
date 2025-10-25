# db/migrate/20251017040000_relax_state_code_on_ach.rb
class RelaxStateCodeOnAch < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    change_column_null :payments_ach_routings, :state_code, true

    # drop old validated constraint (if present)
    remove_check_constraint :payments_ach_routings, name: "chk_par_state_code", if_exists: true

    # add new UNVALIDATED constraint
    add_check_constraint :payments_ach_routings,
      "state_code IS NULL OR state_code ~ '^[A-Z]{2}$'",
      name: "chk_par_state_code",
      validate: false
  end

  def down
    remove_check_constraint :payments_ach_routings, name: "chk_par_state_code", if_exists: true
    change_column_null :payments_ach_routings, :state_code, false
    add_check_constraint :payments_ach_routings,
      "state_code ~ '^[A-Z]{2}$'",
      name: "chk_par_state_code"
  end
end
