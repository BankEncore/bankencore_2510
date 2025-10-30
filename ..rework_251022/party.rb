# app/models/party.rb
class Party < ApplicationRecord
  self.table_name = "parties_parties"

  # Associations
  has_many :names,            class_name: "Parties::Name",        foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :phones,           class_name: "Parties::Phone",       foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :postal_addresses, class_name: "Parties::PostalAddress", foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :email_addresses,  class_name: "Parties::EmailAddress",  foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :web_addresses,    class_name: "Parties::WebAddress",    foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :tax_ids,          class_name: "Parties::TaxId",       foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :identities,       class_name: "Parties::Identity",    foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :disclosures,      class_name: "Parties::Disclosure",  foreign_key: :party_id, inverse_of: :party, dependent: :destroy

  has_one  :individual,       class_name: "Parties::Individual",  foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_one  :organization,     class_name: "Parties::Organization", foreign_key: :party_id, inverse_of: :party, dependent: :destroy

  belongs_to :preferred_name,
             class_name: "Parties::Name",
             foreign_key: :preferred_party_name_id,
             optional: true

  # Scopes
  scope :customers, -> { where(relationship_to_institution_code: "customer") }

  # Validations
  validates :public_id, presence: true, uniqueness: true
  validates :profile_number, presence: true, uniqueness: true, format: { with: /\A\d{10}\z/ }
  validates :relationship_to_institution_code, presence: true

  # DB will enforce same-party preferred_name via composite FK.
  # On create, set FK if a preferred name exists.
  after_commit :set_preferred_name_fk_on_create, on: :create

  before_validation :ensure_public_id, :ensure_profile_number, :ensure_defaults, on: :create

  # Convenience
  delegate :full_name, to: :preferred_name, prefix: false, allow_nil: true
  def display_name
    full_name || names.order(preferred: :desc, id: :asc).limit(1).pick(:full_name)
  end

  private

  def set_preferred_name_fk_on_create
    pid = names.where(preferred: true).limit(1).pick(:id)
    update_column(:preferred_party_name_id, pid) if pid.present?
  end

  def ensure_public_id
    self.public_id ||= SecureRandom.uuid
  end

  def ensure_profile_number
    return if profile_number.present?
    pn = self.class.connection.select_value("SELECT alloc_party_profile_number()") rescue nil
    return self.profile_number = pn if pn.present?

    base = (Process.clock_gettime(Process::CLOCK_REALTIME, :millisecond) % 9_999_999)
    base = 1001 if base < 1001
    body  = format("%07d", base) + Time.current.strftime("%y")
    sum = 0
    body.reverse.chars.each_with_index do |ch, i|
      d = ch.ord - 48
      d = d * 2; d -= 9 if d > 9 if i.odd?
      sum += d
    end
    self.profile_number = body + ((10 - (sum % 10)) % 10).to_s
  end

  def ensure_defaults
    self.relationship_to_institution_code ||= "customer"
    self.established_on ||= Date.current
  end
end
