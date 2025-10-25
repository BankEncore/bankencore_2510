# app/models/branch.rb
class Branch < ApplicationRecord
  def to_param = public_id
  DAYS = %w[mon tue wed thu fri sat sun].freeze

  belongs_to :country, class_name: "System::Country",
             foreign_key: :country_alpha2, primary_key: :alpha2, optional: true
  has_many :branch_memberships, dependent: :destroy
  has_many :users, through: :branch_memberships

  enum :status, { inactive: 0, active: 1, archived: 2 }, default: :active

  before_validation do
    self.code           = code&.strip&.upcase
    self.time_zone      = time_zone&.strip.presence || "UTC"
    self.country_alpha2 = country_alpha2&.strip&.upcase
    self.region_code    = region_code&.strip&.upcase
    self.email          = email&.strip&.downcase
  end
  before_validation :normalize_phones

  validates :code, presence: true, uniqueness: true, length: { maximum: 16 },
                   format: { with: /\A[A-Z0-9_-]+\z/ }
  validates :name, :time_zone, presence: true
  validates :country_alpha2, presence: true, format: { with: /\A[A-Z]{2}\z/ }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, :fax, length: { maximum: 32 }, allow_blank: true
  validates :postal_code, length: { maximum: 16 }, allow_blank: true
  validates :latitude,  numericality: { greater_than_or_equal_to: -90,  less_than_or_equal_to: 90  }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  def phone_parsed   = ::Phonelib.parse(phone, country_alpha2)
  def fax_parsed     = ::Phonelib.parse(fax,   country_alpha2)

  def phone_e164     = phone_parsed.valid? ? phone_parsed.e164 : phone
  def phone_display  = phone_parsed.valid? ? phone_parsed.international : phone
  def fax_e164       = fax_parsed.valid? ? fax_parsed.e164 : fax
  def fax_display    = fax_parsed.valid? ? fax_parsed.international : fax

  def hours_for(day)
    (operating_hours || {})[day]
  end

  def hour_value(day, key)
    h = hours_for(day)
    h.is_a?(Hash) ? h[key] : nil
  end

  validate :validate_operating_hours_times

  private

  def normalize_phones
    if phone.present?
      p = ::Phonelib.parse(phone, country_alpha2)
      self.phone = p.valid? ? p.e164 : phone.strip
    end
    if fax.present?
      p = ::Phonelib.parse(fax, country_alpha2)
      self.fax = p.valid? ? p.e164 : fax.strip
    end
  end

  def validate_operating_hours_times
    re = /\A[0-2]\d:[0-5]\d\z/
    DAYS.each do |d|
      h = (operating_hours || {})[d]
      next if h.nil?
      o = h["open"]; c = h["close"]
      errors.add(:operating_hours, "#{d} open invalid")  unless o.is_a?(String) && o.match?(re)
      errors.add(:operating_hours, "#{d} close invalid") unless c.is_a?(String) && c.match?(re)
    end
  end
end
