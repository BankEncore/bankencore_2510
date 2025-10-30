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

  # 1:1 guard (DB unique on party_id recommended)
  validates :party_id, presence: true, uniqueness: true

  # Code hygiene
  CODE_RE = /\A[a-z0-9_.-]+\z/
  with_options allow_nil: true, format: { with: CODE_RE } do
    validates :organization_type_code
    validates :tax_exempt_code
  end

  # Country hygiene (ISO 3166-1 alpha-2; DB FK recommended)
  validates :residence_country, length: { is: 2 }, allow_nil: true
  before_validation { self.residence_country = residence_country&.upcase }

  # Scopes
  scope :of_type, ->(code) { where(organization_type_code: code) }
  scope :in_country, ->(alpha2) { where(residence_country: alpha2.to_s.upcase) }
  scope :with_naics, -> { where.not(system_naics_code_id: nil) }

  # Convenience
  delegate :title, to: :naics_code, prefix: true, allow_nil: true
end
