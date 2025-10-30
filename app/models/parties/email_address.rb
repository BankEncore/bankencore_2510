# app/models/parties/email_address.rb
class Parties::EmailAddress < ApplicationRecord
  self.table_name = "parties_email_addresses"

  before_validation do
    self.email_type_code ||= "primary"     # test seeds include "primary"
  end

  belongs_to :party,
    class_name: "Parties::Party",
    foreign_key: :party_id,
    inverse_of: :email_addresses

  # Encryption + normalization
  encrypts :email, deterministic: true, downcase: true
  normalizes :email, with: ->(v) { v.to_s.strip.downcase }

  # Codes
  CODE_RE = /\A[a-z0-9_.-]+\z/
  validates :email_type_code, allow_nil: true, format: { with: CODE_RE }

  # Email format (pragmatic)
  EMAIL_RE = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
  validates :email, presence: true, format: { with: EMAIL_RE }

  # Uniqueness per party + type
  validates :email, uniqueness: { scope: %i[party_id email_type_code] }

  # Preferred flag and window
  validates :preferred, inclusion: { in: [ true, false ] }
  validate  :single_preferred_per_party, if: :preferred?
  validate  :valid_range

  # Scopes
  scope :preferred, -> { where(preferred: true) }
  scope :verified,  -> { where.not(verified_at: nil) }
  scope :active_on, ->(d) {
    where("(valid_from IS NULL OR valid_from <= ?) AND (valid_to IS NULL OR valid_to >= ?)", d, d)
  }

  # Convenience
  def domain = email&.split("@")&.last
  def local  = email&.split("@")&.first

  private

  def single_preferred_per_party
    if party.email_addresses.where(preferred: true).where.not(id: id).exists?
      errors.add(:preferred, "already set for this party")
    end
  end

  def valid_range
    return if valid_from.blank? || valid_to.blank?
    errors.add(:valid_to, "must be on or after valid_from") if valid_to < valid_from
  end
end
