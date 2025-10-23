# app/models/system/currency.rb
# new
class System::Currency < ApplicationRecord
  audited if respond_to?(:audited)

  self.table_name = "system_currencies"

  # Associations
  has_many :country_links,
           class_name: "System::CountryCurrency",
           foreign_key: :currency_code,
           primary_key: :code,
           inverse_of: :currency,
           dependent: :restrict_with_exception

  # Normalization
  before_validation do
    self.code    = code&.upcase&.strip
    self.numeric = numeric&.strip
    self.numeric = "%03d" % numeric.to_i if numeric&.match?(/\A\d+\z/) && numeric.length != 3
  end

  # Validations
  validates :code,
           presence: true,
           length: { is: 3 },
           format: { with: /\A[A-Z]{3}\z/ },
           uniqueness: { case_sensitive: false }

  validates :numeric,
           presence: true,
           length: { is: 3 },
           format: { with: /\A[0-9]{3}\z/ },
           uniqueness: true

  validates :name, presence: true
  validates :minor_units, presence: true, inclusion: { in: [0, 1, 2, 3] }

  validates :public_id, presence: true, uniqueness: true, if: -> { has_attribute?(:public_id) }

  # Optional fields
  validates :symbol, length: { maximum: 8 }, allow_nil: true
  validates :unicode_codepoint, numericality: { greater_than: 0, less_than: 0x110000 }, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_code, ->(c) { where(code: c.to_s.upcase) }
  scope :by_numeric, ->(n) { where(numeric: n.to_s.rjust(3, "0")) }

  # Convenience
  def unicode_hex
    return nil unless unicode_codepoint
    "U+%04X" % unicode_codepoint
  end

  def display_name
    [name, "(#{code})"].join(" ")
  end

  # Serialization defaults
  def as_json(options = {})
    super({ only: %i[code numeric name full_name minor_units symbol unicode_codepoint active],
            methods: %i[unicode_hex],
            include: {},
            }.merge(options || {}))
  end
end
