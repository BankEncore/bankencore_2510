# app/models/system/currency.rb
class System::Currency < ApplicationRecord
  include HasPublicId
  self.table_name = "system_currencies"

  has_many :country_currencies,
           class_name: "System::CountryCurrency",
           foreign_key: :currency_id,
           dependent: :destroy

  # existing validations are fine; keep money-gem data authoritative
end

# app/models/system/country_currency.rb
class System::CountryCurrency < ApplicationRecord
  include HasPublicId
  self.table_name = "system_country_currencies"

  belongs_to :country,  class_name: "System::Country", foreign_key: :country_id
  belongs_to :currency, class_name: "System::Currency"

  scope :active_on, ->(date) {
    where("valid_from IS NULL OR valid_from <= ?", date)
      .where("valid_to   IS NULL OR valid_to   >= ?", date)
  }
end
