# app/models/parties/tax_id.rb
class Parties::TaxId < ApplicationRecord
  self.table_name = "parties_tax_ids"

  belongs_to :party,
    class_name: "Parties::Party",
    foreign_key: :party_id,
    inverse_of: :tax_ids

  # Encryption + normalization
  encrypts :value, deterministic: true
  normalizes :value, with: ->(v) { v.to_s.unicode_normalize(:nfc).downcase.gsub(/[^a-z0-9]/, "") }

  before_validation { self.country = country&.upcase }

  CODE_RE = /\A[a-z0-9_.-]+\z/
  validates :tax_id_type_code, presence: true, format: { with: CODE_RE }
  validates :value, presence: true
  validates :country, allow_nil: true, format: { with: /\A[A-Z]{2}\z/ }

  # Shapes
  validate :value_shape_by_type
  validate :us_country_required_for_us_types

  # Require W-8 for non-US
  validate :w8_required_for_non_us, if: -> { country.present? && country != "US" }

  # Uniqueness per party + type
  validates :value, uniqueness: { scope: %i[party_id tax_id_type_code] }

  # IRS B-Notice sequencing
  validate :b_notice_sequence

  scope :of_type,    ->(code) { where(tax_id_type_code: code) }
  scope :in_country, ->(a2)   { where(country: a2.to_s.upcase) }

  def last4 = value&.last(4)

  private

  def value_shape_by_type
    case tax_id_type_code
    when "ssn", "ein"
      errors.add(:value, "must be 9 digits") unless value&.match?(/\A\d{9}\z/)
    when "itin"
      errors.add(:value, "must be 9 digits starting with 9") unless value&.match?(/\A9\d{8}\z/)
    else
      # non-US types: allow 4–32 lowercase alphanumerics after normalization
      errors.add(:value, "must be 4–32 alphanumerics") unless value&.match?(/\A[a-z0-9]{4,32}\z/)
    end
  end

  def us_country_required_for_us_types
    return unless %w[ssn itin ein].include?(tax_id_type_code)
    errors.add(:country, "must be US for #{tax_id_type_code.upcase}") unless country == "US"
  end

  def w8_required_for_non_us
    errors.add(:w8_signed_on, "is required for non-US") if w8_signed_on.blank?
  end

  def b_notice_sequence
    if b_notice2_sent_on.present? && b_notice1_sent_on.blank?
      errors.add(:b_notice1_sent_on, "must be present before B-Notice 2")
    end
    if b_notice1_sent_on && b_notice2_sent_on && b_notice2_sent_on < b_notice1_sent_on
      errors.add(:b_notice2_sent_on, "must be on or after B-Notice 1")
    end
  end
end
