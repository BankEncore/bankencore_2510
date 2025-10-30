# app/models/parties/web_address.rb
class Parties::WebAddress < ApplicationRecord
  self.table_name = "parties_web_addresses"

  belongs_to :party, class_name: "Parties::Party", inverse_of: :web_addresses

  # Normalize
  before_validation :normalize_url

  # Preferred flag and date window
  validates :preferred, inclusion: { in: [ true, false ] }
  validate  :single_preferred_per_party, if: :preferred?
  validate  :valid_range

  validates :url, presence: true
  validates :url, format: { with: /\Ahttps?:\/\/[^\s]+\z/i, message: "must be http(s) URL" }

  # Scopes
  scope :preferred, -> { where(preferred: true) }
  scope :active_on, ->(d) {
    where("(valid_from IS NULL OR valid_from <= ?) AND (valid_to IS NULL OR valid_to >= ?)", d, d)
  }

  # Convenience
  def host
    URI.parse(url).host rescue nil
  end

  private

  def normalize_url
    return if url.blank?
    u = url.strip
    u = "https://#{u}" unless u[%r{\Ahttps?://}i]
    self.url = u
  end

  def single_preferred_per_party
    if party.web_addresses.where(preferred: true).where.not(id: id).exists?
      errors.add(:preferred, "already set for this party")
    end
  end

  def valid_range
    return if valid_from.blank? || valid_to.blank?
    errors.add(:valid_to, "must be on or after valid_from") if valid_to < valid_from
  end
end
