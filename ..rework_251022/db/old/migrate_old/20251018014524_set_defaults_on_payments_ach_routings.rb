# db/migrate/20251018000001_set_defaults_on_payments_ach_routings.rb
class SetDefaultsOnPaymentsAchRoutings < ActiveRecord::Migration[7.1]
  def up
    safety_assured {
    execute "UPDATE payments_ach_routings SET office_code='0' WHERE office_code IS NULL"
    execute "UPDATE payments_ach_routings SET record_type_code='0' WHERE record_type_code IS NULL"
    execute "UPDATE payments_ach_routings SET institution_status_code='1' WHERE institution_status_code IS NULL"
    execute "UPDATE payments_ach_routings SET data_view_code='1' WHERE data_view_code IS NULL"
    execute "UPDATE payments_ach_routings SET new_routing_number='000000000' WHERE new_routing_number IS NULL OR new_routing_number=''"

    change_column_default :payments_ach_routings, :office_code, "0"
    change_column_default :payments_ach_routings, :record_type_code, "0"
    change_column_default :payments_ach_routings, :institution_status_code, "1"
    change_column_default :payments_ach_routings, :data_view_code, "1"
    change_column_default :payments_ach_routings, :new_routing_number, "000000000"
  }
  end

  def down
    change_column_default :payments_ach_routings, :office_code, nil
    change_column_default :payments_ach_routings, :record_type_code, nil
    change_column_default :payments_ach_routings, :institution_status_code, nil
    change_column_default :payments_ach_routings, :data_view_code, nil
    change_column_default :payments_ach_routings, :new_routing_number, nil
  end
end
