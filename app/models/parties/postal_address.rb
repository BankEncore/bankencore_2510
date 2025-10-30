# app/models/parties/postal_address.rb
class Parties::PostalAddress < ApplicationRecord
  self.table_name = "parties_postal_addresses"

  belongs_to :party,  class_name: "Parties::Party",          inverse_of: :postal_addresses
  belongs_to :region, class_name: "System::Region", foreign_key: :system_region_id, optional: true

  # Normalize
  before_validation do
    self.country     = country&.upcase
    self.postal_code = postal_code&.strip
    %i[line1 line2 line3 line4 city].each { |a| self[a] = self[a]&.strip.presence }
  end

  # Codes
  CODE_RE = /\A[a-z0-9_.-]+\z/
  validates :address_use_code,  allow_nil: true, format: { with: CODE_RE }
  validates :address_type_code, allow_nil: true, format: { with: CODE_RE }

  # Country ISO-2 (FK recommended)
  validates :country, allow_nil: true, format: { with: /\A[A-Z]{2}\z/ }

  # Preferred flag
  validates :preferred, inclusion: { in: [ true, false ] }
  validate  :single_preferred_per_party, if: :preferred?

  # Date window (DB also has CHECK)
  validate  :valid_range

  # Scopes
  scope :preferred, -> { where(preferred: true) }
  scope :active_on, ->(d) {
    where("(valid_from IS NULL OR valid_from <= ?) AND (valid_to IS NULL OR valid_to >= ?)", d, d)
  }

  # Convenience
  def display_one_line
    [ line1, line2, line3, line4, city, region&.local_code, postal_code, country ].compact.join(", ")
  end

  private

  def single_preferred_per_party
    if party.postal_addresses.where(preferred: true).where.not(id: id).exists?
      errors.add(:preferred, "already set for this party")
    end
  end

  def valid_range
    return if valid_from.blank? || valid_to.blank?
    errors.add(:valid_to, "must be on or after valid_from") if valid_to < valid_from
  end
end
