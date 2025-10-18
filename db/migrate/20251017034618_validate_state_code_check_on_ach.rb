# db/migrate/20251017040100_validate_state_code_check_on_ach.rb
class ValidateStateCodeCheckOnAch < ActiveRecord::Migration[8.0]
  def change
    validate_check_constraint :payments_ach_routings, name: "chk_par_state_code"
  end
end
