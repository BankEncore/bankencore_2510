# app/models/parties/identity.rb
class Parties::Identity < ApplicationRecord
  self.table_name = "parties_identities"

  belongs_to :party
  belongs_to :region, class_name: "System::Region", foreign_key: :system_region_id, optional: true

  # Encryption + normalization
  encrypts :number, deterministic: true, downcase: true
  normalizes :number, with: ->(v) { v.to_s.unicode_normalize(:nfc).downcase.gsub(/[^a-z0-9]/, "") }

  TYPES = %w[passport driver_license national_id other].freeze

  # Validations
  validates :identity_type_code, presence: true, inclusion: { in: TYPES }
  validates :number,
            format: { with: /\A[a-z0-9]*\z/ },
            length: { maximum: 64 },
            allow_blank: true
  validates :issuing_country,
            format: { with: /\A[A-Z]{2}\z/ },
            allow_blank: true
  validates :issuer_name, length: { maximum: 100 }, allow_blank: true
  validates :number, uniqueness: { scope: %i[party_id identity_type_code], case_sensitive: false }, allow_blank: true

  validate :expiry_after_issue

  # Scopes
  scope :active,  -> { where("expires_on IS NULL OR expires_on >= CURRENT_DATE") }
  scope :expired, -> { where("expires_on < CURRENT_DATE") }

  private

  def expiry_after_issue
    return if issued_on.blank? || expires_on.blank?
    errors.add(:expires_on, "must be on or after issued_on") if expires_on < issued_on
  end
end
