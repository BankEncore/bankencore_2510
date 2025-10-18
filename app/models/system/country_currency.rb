class System::CountryCurrency < ApplicationRecord
  self.table_name = "system_country_currencies"

  belongs_to :country,  class_name: "System::Country", foreign_key: :country_id
  belongs_to :currency, class_name: "System::Currency"

  scope :active_on, ->(date) {
    where("valid_from IS NULL OR valid_from <= ?", date)
      .where("valid_to   IS NULL OR valid_to   >= ?", date)
  }
end
