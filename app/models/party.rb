# app/models/party.rb
class Party < ApplicationRecord
  self.table_name = "parties_parties"

  has_many :names,          class_name: "Parties::Name",          dependent: :destroy
  has_many :phones,         class_name: "Parties::Phone",         dependent: :destroy
  has_many :postal_addresses, class_name: "Parties::PostalAddress", dependent: :destroy
  has_many :email_addresses,  class_name: "Parties::EmailAddress",  dependent: :destroy
  has_many :web_addresses,    class_name: "Parties::WebAddress",    dependent: :destroy
  has_many :tax_ids,        class_name: "Parties::TaxId",         dependent: :destroy
  has_many :identities,     class_name: "Parties::Identity",      dependent: :destroy
  has_many :disclosures,    class_name: "Parties::Disclosure",    dependent: :destroy

  has_one  :individual,     class_name: "Parties::Individual",    dependent: :destroy
  has_one  :organization,   class_name: "Parties::Organization",  dependent: :destroy

  belongs_to :preferred_name, class_name: "Parties::Name", foreign_key: :preferred_party_name_id, optional: true

  before_validation :ensure_profile_number, on: :create

  # Scopes
  scope :customers, -> { where(relationship_to_institution_code: "customer") }

  # Callbacks to keep preferred_name fk in sync
  after_commit :sync_preferred_name_id, if: -> { preferred_name_id_missing? }

  private
  def preferred_name_id_missing?
    preferred_party_name_id.nil? && names.where(preferred: true).exists?
  end
  def sync_preferred_name_id
    update_column(:preferred_party_name_id, names.find_by(preferred: true)&.id)
  end
  def ensure_profile_number
    return if profile_number.present?
    # Prefer DB allocator if present
    self.profile_number = self.class.connection.select_value("SELECT alloc_party_profile_number()")
  rescue ActiveRecord::StatementInvalid
    # Pure-Ruby fallback: 7d seq from time, 2d year, Luhn check
    base = (Time.now.to_f * 1000).to_i % 9_999_999
    base = 1001 if base < 1001
    seq7 = format("%07d", base)
    yy   = Time.now.strftime("%y")
    body = "#{seq7}#{yy}"
    sum = 0
    dbl = false
    body.reverse.each_char do |ch|
      d = ch.ord - 48
      d = d * 2
      d -= 9 if d > 9
      sum += d
      dbl = !dbl
    end
    check = (10 - (sum % 10)) % 10
    self.profile_number = "#{body}#{check}"
  end
end
