# app/models/parties/individual.rb
class Parties::Individual < ApplicationRecord
  self.table_name  = "parties_individuals"
  self.primary_key = :party_id

  belongs_to :party,
    class_name: "Parties::Party",
    foreign_key: :party_id,
    inverse_of: :individual

  # PII
  encrypts :birth_date

  # 1:1 guard (DB also has unique index on party_id)
  validates :party_id, presence: true, uniqueness: true

  # Code hygiene
  CODE_RE = /\A[a-z0-9_.-]+\z/
  with_options allow_nil: true, format: { with: CODE_RE } do
    validates :gender_code
    validates :marital_status_code
    validates :immigration_status_code
    validates :education_level_code
    validates :home_ownership_code
    validates :race_code
    validates :employment_type_code
    validates :occupation_code
  end

  # Country hygiene (ISO 3166-1 alpha-2; FK enforced in DB)
  validates :residence_country, length: { is: 2 }, allow_nil: true
  before_validation { self.residence_country = residence_country&.upcase }

  # Scopes
  scope :in_country, ->(alpha2) { where(residence_country: alpha2.to_s.upcase) }

  # Convenience
  def age(as_of: Date.current)
    return nil unless birth_date
    y = as_of.year - birth_date.year
    y -= 1 if as_of.yday < birth_date.yday
    y
  end
end
