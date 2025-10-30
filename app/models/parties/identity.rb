# app/models/parties/identity.rb
class Parties::Identity < ApplicationRecord
  self.table_name = "parties_identities"

  belongs_to :party,  class_name: "Parties::Party",          inverse_of: :identities
  belongs_to :region, class_name: "System::Region", foreign_key: :system_region_id, optional: true

  # Encryption + normalization
  encrypts :number, deterministic: true, downcase: true
  normalizes :number, with: ->(v) { v.to_s.unicode_normalize(:nfc).downcase.gsub(/[^a-z0-9]/, "") }
  before_validation { self.issuing_country = issuing_country&.upcase }

  # Hygiene
  CODE_RE = /\A[a-z0-9_.-]+\z/
  validates :identity_type_code, presence: true, format: { with: CODE_RE }
  validates :number, format: { with: /\A[a-z0-9]*\z/ }, length: { maximum: 64 }, allow_blank: true
  validates :issuer_name, length: { maximum: 100 }, allow_blank: true
  validates :issuing_country, format: { with: /\A[A-Z]{2}\z/ }, allow_blank: true
  validates :number, uniqueness: { scope: %i[party_id identity_type_code], case_sensitive: false }, allow_blank: true

  # Cross-field checks
  validate :expiry_after_issue
  validate :identity_type_is_allowed
  validate :enforce_type_requirements
  validate :region_matches_country

  # Scopes
  scope :active,  -> { where("expires_on IS NULL OR expires_on >= CURRENT_DATE") }
  scope :expired, -> { where("expires_on < CURRENT_DATE") }

  private

  def expiry_after_issue
    return if issued_on.blank? || expires_on.blank?
    errors.add(:expires_on, "must be on or after issued_on") if expires_on < issued_on
  end

  # Reference membership: parties.identity_types
  def identity_type_is_allowed
    list = System::ReferenceList.find_by(key: "parties.identity_types")
    return unless list
    ok = System::ReferenceValue.exists?(reference_list_id: list.id, code: identity_type_code)
    errors.add(:identity_type_code, "is not in reference list") unless ok
  rescue ActiveRecord::StatementInvalid
    # refs not migrated; skip
  end

  # Enforce per-type requirements from reference value metadata.requires
  # expects keys: country, region, issue_date, expiration_date, issuer_freeflow, number
  def enforce_type_requirements
    rv = ref_value_for(identity_type_code)
    return unless rv
    req = (rv.metadata || {}).fetch("requires", {})
    require_if(req["country"],         :issuing_country)
    require_if(req["region"],          :system_region_id)
    require_if(req["issue_date"],      :issued_on)
    require_if(req["expiration_date"], :expires_on)
    require_if(req["issuer_freeflow"], :issuer_name)
    require_if(req["number"],          :number)
  end

  def ref_value_for(code)
    list = System::ReferenceList.find_by(key: "parties.identity_types")
    return nil unless list
    System::ReferenceValue.find_by(reference_list_id: list.id, code: code)
  rescue ActiveRecord::StatementInvalid
    nil
  end

  def require_if(setting, attr)
    case setting
    when "required" then errors.add(attr, "is required for this identity type") if self[attr].blank?
      # "optional" or "none" need no action
    end
  end

  # If both set, region.country_alpha2 must equal issuing_country
  def region_matches_country
    return if issuing_country.blank? || region.nil?
    if region.country_alpha2 != issuing_country
      errors.add(:system_region_id, "must belong to issuing_country")
    end
  end
end
