# db/migrate/20251031035447_change_birth_date_to_text.rb
class ChangeBirthDateToText < ActiveRecord::Migration[7.2]
  def up
    safety_assured { change_column :parties_individuals, :birth_date, :text }
  end

  def down
    safety_assured { change_column :parties_individuals, :birth_date, :date }
  end
end
