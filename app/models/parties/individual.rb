# app/models/parties/individual.rb
class Parties::Individual < ApplicationRecord
  self.table_name  = "parties_individuals"
  self.primary_key = :party_id

  belongs_to :party,
    class_name: "Parties::Party",
    foreign_key: :party_id,
    inverse_of:  :individual

  # PII (non-deterministic is fine for DOB; you usually don't exact-match on it)
  attribute :birth_date, :date
  encrypts  :birth_date, deterministic: true

  # 1:1 guard (DB also has unique index on party_id)
  validates :party_id, uniqueness: true, allow_nil: true

  # Country hygiene (ISO 3166-1 alpha-2; FK enforced in DB)
  validates :residence_country, length: { is: 2 }, allow_nil: true

  # Code hygiene (lowercase; machine-safe)
  CODE_RE = /\A[a-z0-9_.-]+\z/
  CODE_KEYS = %i[
    gender_code marital_status_code immigration_status_code education_level_code
    home_ownership_code race_code employment_type_code occupation_code
  ].freeze

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

  # DOB sanity
  validate :birth_date_not_in_future
  validate :birth_date_not_unreasonably_old

  # Normalization
  before_validation :normalize_codes_and_country

  # Scopes
  scope :in_country, ->(alpha2) { where(residence_country: alpha2.to_s.upcase) }
  scope :adults,     ->(as_of = Date.current) { where("birth_date IS NOT NULL AND birth_date <= ?", as_of - 18.years) }
  scope :minors,     ->(as_of = Date.current) { where("birth_date IS NOT NULL AND birth_date >  ?", as_of - 18.years) }
  scope :age_between, ->(min_y, max_y, as_of = Date.current) {
    # inclusive age range: [min_y, max_y]
    min_date = as_of - max_y.years
    max_date = as_of - min_y.years
    where(birth_date: min_date..max_date)
  }

  # Convenience
  def age(as_of: Date.current)
    return nil unless birth_date
    y = as_of.year - birth_date.year
    y -= 1 if as_of.yday < birth_date.yday
    y
  end

  # OPTIONAL: reference-backed inclusions once lists are loaded
  # Uncomment when System::ReferenceValue is wired and seeded
  #
  # validate -> { ref_inclusion!("genders", :gender_code) }
  # validate -> { ref_inclusion!("marital_statuses", :marital_status_code) }
  # ... and so on

  private

  def normalize_codes_and_country
    self.residence_country = residence_country&.upcase
    CODE_KEYS.each do |k|
      v = send(k)
      send("#{k}=", v.to_s.strip.downcase.presence) if v.present?
    end
  end

  def birth_date_not_in_future
    return unless birth_date
    errors.add(:birth_date, "cannot be in the future") if birth_date > Date.current
  end

  def birth_date_not_unreasonably_old
    return unless birth_date
    oldest = Date.current - 120.years
    errors.add(:birth_date, "is too far in the past") if birth_date < oldest
  end

  def party_id_immutable
    if will_save_change_to_party_id?
      errors.add(:party_id, "cannot be changed")
    end
  end

  # When ready to enforce reference lists, use:
  # def ref_inclusion!(list_key, attr)
  #   code = send(attr)
  #   return if code.blank?
  #   list = System::ReferenceList.find_by(key: "parties.#{list_key}")
  #   return unless list # fail-open until seeds exist
  #   allowed = System::ReferenceValue.where(reference_list_id: list.id, active: true).pluck(:code)
  #   errors.add(attr, "is not in #{list_key}") unless allowed.include?(code)
  # end
end
