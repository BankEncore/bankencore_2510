# app/models/system/country.rb
# new
class System::Country < ApplicationRecord
  self.table_name = "system_countries"

  # Assocs
  has_many :regions,
           class_name: "System::Region",
           foreign_key: :country_alpha2,
           primary_key: :alpha2,
           inverse_of: :country,
           dependent: :restrict_with_exception

  has_many :currency_links,
           class_name: "System::CountryCurrency",
           foreign_key: :country_alpha2,
           primary_key: :alpha2,
           inverse_of: :country

  # Normalize
  before_validation do
    self.alpha2 = alpha2&.strip&.upcase
    self.alpha3 = alpha3&.strip&.upcase
    self.numeric = numeric&.strip
    self.numeric = "%03d" % numeric.to_i if numeric&.match?(/\A\d+\z/) && numeric.length != 3
    self.currency_primary_code = currency_primary_code&.strip&.upcase if has_attribute?(:currency_primary_code)
  end

  # Validate ISO codes
  validates :alpha2,  presence: true, length: { is: 2 },  format: { with: /\A[A-Z]{2}\z/ },  uniqueness: true
  validates :alpha3,  presence: true, length: { is: 3 },  format: { with: /\A[A-Z]{3}\z/ }, uniqueness: true
  validates :numeric, presence: true, length: { is: 3 },  format: { with: /\A[0-9]{3}\z/ }, uniqueness: true

  # Names and flags
  validates :iso_short_name, presence: true
  validates :postal_code_required, inclusion: { in: [true, false] }

  # Optional primary currency convenience
  validates :currency_primary_code, format: { with: /\A[A-Z]{3}\z/ }, allow_nil: true
end
