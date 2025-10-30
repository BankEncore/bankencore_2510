# app/models/parties/phone.rb
class Parties::Phone < ApplicationRecord
  self.table_name = "parties_phones"

  belongs_to :party, class_name: "Parties::Party", foreign_key: :party_id, inverse_of: :phones

  # Normalize
  # app/models/parties/phone.rb
  before_validation { self.phone_type_code ||= "mobile" }

  # E.164 (7–15 digits is common; use 8–15 to avoid junk)
  validates :e164, format: { with: /\A\+\d{10,15}\z/, message: "must be in E.164 format" }

  # Preferred flag
  validates :preferred, inclusion: { in: [ true, false ] }
  validate  :single_preferred_per_party, if: :preferred?

  # Date window (DB also has CHECK)
  validate  :valid_range

  # Scopes
  scope :preferred,  -> { where(preferred: true) }
  scope :verified,   -> { where.not(verified_at: nil) }
  scope :unverified, -> { where(verified_at: nil) }
  scope :active_on,  ->(d) {
    where("(valid_from IS NULL OR valid_from <= ?) AND (valid_to IS NULL OR valid_to >= ?)", d, d)
  }

  # Convenience
  def last4 = e164&.gsub(/\D/, "")&.last(4)

  private

  def single_preferred_per_party
    if party.phones.where(preferred: true).where.not(id: id).exists?
      errors.add(:preferred, "already set for this party")
    end
  end

  def valid_range
    return if valid_from.blank? || valid_to.blank?
    errors.add(:valid_to, "must be on or after valid_from") if valid_to < valid_from
  end
end
