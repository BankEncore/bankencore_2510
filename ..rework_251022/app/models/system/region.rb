# app/models/system/region.rb
# new
class System::Region < ApplicationRecord
  self.table_name = "system_regions"

  belongs_to :country,
             class_name: "System::Country",
             foreign_key: :country_alpha2,
             primary_key: :alpha2,
             inverse_of: :regions

  # Normalize
  before_validation do
    self.country_alpha2 = country_alpha2&.strip&.upcase
    self.region_code    = region_code&.strip&.upcase
    self.kind           = kind&.strip&.downcase
    self.iso_code       = [country_alpha2, region_code].join("-") if country_alpha2.present? && region_code.present?
  end

  # Validations
  validates :country_alpha2, presence: true, length: { is: 2 }, format: { with: /\A[A-Z]{2}\z/ }
  validates :region_code,    presence: true, length: { maximum: 10 }, format: { with: /\A[A-Z0-9\-]+\z/ }
  validates :name,           presence: true
  validates :kind,           presence: true, inclusion: {
    in: %w[state province territory department prefecture region municipality canton oblast autonomous_area],
    message: "unsupported kind"
  }
  validates :iso_code,       presence: true, uniqueness: true
  validates :region_code,    uniqueness: { scope: :country_alpha2 }

  scope :active, -> { where(active: true) }
end
