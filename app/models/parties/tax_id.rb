# app/models/parties/tax_id.rb
class Parties::TaxId < ApplicationRecord
  self.table_name = "parties_tax_ids"

  belongs_to :party

  # Encryption + normalization
  encrypts :value, deterministic: true, downcase: true
  normalizes :value, with: ->(v) { v.to_s.unicode_normalize(:nfc).downcase.gsub(/[^a-z0-9]/, "") }

  # Types you accept (adjust to your set)
  TYPES = %w[ssn itin ein tin vat other].freeze

  # Validations
  validates :tax_id_type_code, presence: true, inclusion: { in: TYPES }
  validates :value, presence: true, format: { with: /\A[a-z0-9]*\z/ }, length: { in: 4..32 }
  validates :value, uniqueness: { scope: %i[party_id tax_id_type_code] } # matches DB composite unique index
  validates :country, allow_nil: true, format: { with: /\A[A-Z]{2}\z/ }  # FK enforces existence

  validate :b_notice_sequence
  validate :w8_needed_for_non_us, if: -> { country.present? && country != "US" }

  private

  def b_notice_sequence
    if b_notice2_sent_on.present? && b_notice1_sent_on.blank?
      errors.add(:b_notice1_sent_on, "must be present before B-Notice 2")
    end
    if b_notice1_sent_on && b_notice2_sent_on && b_notice2_sent_on < b_notice1_sent_on
      errors.add(:b_notice2_sent_on, "must be on or after B-Notice 1")
    end
  end

  def w8_needed_for_non_us
    errors.add(:w8_signed_on, "required for non-US tax IDs") if w8_signed_on.blank?
  end
end
