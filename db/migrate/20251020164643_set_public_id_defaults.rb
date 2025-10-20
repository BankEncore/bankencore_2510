# db/migrate/20251020170200_set_public_id_defaults.rb
class SetPublicIdDefaults < ActiveRecord::Migration[8.0]
  def change
    change_column_default :system_reference_lists,    :public_id, -> { "gen_random_uuid()" }
    change_column_default :system_reference_values,   :public_id, -> { "gen_random_uuid()" }
    change_column_default :system_naics_codes,        :public_id, -> { "gen_random_uuid()" }
    change_column_default :system_country_currencies, :public_id, -> { "gen_random_uuid()" }
  end
end
