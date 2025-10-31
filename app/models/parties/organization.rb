# app/models/parties/organization.rb
class Parties::Organization < ApplicationRecord
  self.table_name  = "parties_organizations"
  self.primary_key = :party_id

  belongs_to :party,
    class_name: "Parties::Party",
    foreign_key: :party_id,
    inverse_of: :organization

  belongs_to :naics_code,
             class_name: "System::NaicsCode",
             foreign_key: :system_naics_code_id,
             optional: true

  # 1:1 guard (DB should also have UNIQUE on party_id)
  validates :party_id, uniqueness: true, allow_nil: true
  validate  :party_id_immutable, on: :update

  # Country hygiene (ISO 3166-1 alpha-2; FK recommended/enforced)
  validates :residence_country, length: { is: 2 }, allow_nil: true

  # Machine-safe codes (lowercase, ascii-ish)
  CODE_RE = /\A[a-z0-9_.-]+\z/
  with_options allow_nil: true, format: { with: CODE_RE } do
    validates :organization_type_code
    validates :tax_exempt_code
  end

  # Dates
  validates :established_on, presence: true
  validate :established_on_not_in_future
  validate :established_on_reasonable_past
  # validate  :naics_consistency   # ← enable if you want the FK/text check

  # Normalization
  before_validation :normalize_codes_and_country

  # Scopes
  scope :of_type,     ->(code) { where(organization_type_code: code.to_s.downcase) }
  scope :in_country,  ->(a2)   { where(residence_country: a2.to_s.upcase) }
  scope :with_naics,  ->       { where.not(system_naics_code_id: nil) }
  scope :established_between, ->(from, to) { where(established_on: from..to) }

  # Convenience
  delegate :title, to: :naics_code, prefix: true, allow_nil: true

  validates :established_on, presence: true
  validates :residence_country, length: { is: 2 }, allow_nil: true
  validate :naics_consistency


  # Optional: reference-backed inclusions once lists are seeded
  # validate -> { ref_inclusion!("organization_types", :organization_type_code) }
  # validate -> { ref_inclusion!("tax_exempt_types",  :tax_exempt_code) }

  private

  def normalize_codes_and_country
    self.residence_country      = residence_country.to_s.strip.upcase.presence
    self.organization_type_code = organization_type_code.to_s.strip.downcase.presence
    self.tax_exempt_code        = tax_exempt_code.to_s.strip.downcase.presence
  end

  def established_on_not_in_future
    return unless established_on
    errors.add(:established_on, "cannot be in the future") if established_on > Date.current
  end

  def established_on_reasonable_past
    return unless established_on
    floor = Date.new(1800, 1, 1)
    errors.add(:established_on, "is unreasonably old") if established_on < floor
  end

  def party_id_immutable
    errors.add(:party_id, "cannot be changed") if will_save_change_to_party_id?
  end

  # When ready to enforce reference lists:
  # def ref_inclusion!(list_key, attr)
  #   code = send(attr)
  #   return if code.blank?
  #   list = System::ReferenceList.find_by(key: "parties.#{list_key}")
  #   return unless list # fail-open until seeded
  #   allowed = System::ReferenceValue.where(reference_list_id: list.id, active: true).pluck(:code)
  #   errors.add(attr, "is not in #{list_key}") unless allowed.include?(code)
  # end
end
