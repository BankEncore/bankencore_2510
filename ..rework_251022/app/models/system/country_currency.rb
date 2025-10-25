# app/models/system/country_currency.rb
# new
class System::CountryCurrency < ApplicationRecord
  self.primary_key = :id

  belongs_to :country,  class_name: "System::Country",   foreign_key: :country_alpha2, primary_key: :alpha2, optional: true
  belongs_to :currency, class_name: "System::Currency",  foreign_key: :currency_code,  primary_key: :code,   optional: true

  validates :country_alpha2, presence: true, format: { with: /\A[A-Z]{2}\z/ }
  validates :currency_code,  presence: true, format: { with: /\A[A-Z]{3}\z/ }
end
