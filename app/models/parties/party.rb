# app/models/parties/party.rb
class Parties::Party < ApplicationRecord
  self.table_name = "parties_parties"

  # --- Subtypes --------------------------------------------------------------
  has_one :individual,
          class_name: "Parties::Individual",
          foreign_key: :party_id,
          inverse_of: :party,
          dependent: :destroy

  has_one :organization,
          class_name: "Parties::Organization",
          foreign_key: :party_id,
          inverse_of: :party,
          dependent: :destroy

  # --- Components ------------------------------------------------------------
  has_many :names,            class_name: "Parties::Name",          foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :email_addresses,  class_name: "Parties::EmailAddress",  foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :phones,           class_name: "Parties::Phone",         foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :postal_addresses, class_name: "Parties::PostalAddress", foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :web_addresses,    class_name: "Parties::WebAddress",    foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :identities,       class_name: "Parties::Identity",      foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :tax_ids,          class_name: "Parties::TaxId",         foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :disclosures,      class_name: "Parties::Disclosure",    foreign_key: :party_id, inverse_of: :party, dependent: :destroy

  has_many :outgoing_relationships,
           class_name: "Parties::Relationship",
           foreign_key: :source_party_id, inverse_of: :source_party, dependent: :destroy

  has_many :incoming_relationships,
           class_name: "Parties::Relationship",
           foreign_key: :target_party_id, inverse_of: :target_party, dependent: :destroy

  # --- Preferred name pointer -----------------------------------------------
  belongs_to :preferred_party_name,
             class_name: "Parties::Name",
             optional: true

  # --- Nested attributes (unified form support) ------------------------------
  # IMPORTANT: do NOT use reject_if: :all_blank — we want the selected subtype to be kept
  attr_accessor :profile_kind

  accepts_nested_attributes_for :names
  accepts_nested_attributes_for :individual,   update_only: true
  accepts_nested_attributes_for :organization, update_only: true
  # --- Validations -----------------------------------------------------------
  validates :relationship_to_institution_code, presence: true

  # On create, require exactly one subtype to be present (controller force-builds the chosen one)
  validate :one_subtype_on_create, on: :create

  # On any write, prevent both subtypes at once (cheap XOR guard)
  validate :prevent_both_subtypes

  # --- Scopes / Finders ------------------------------------------------------
  scope :people,        -> { where.exists(Parties::Individual.where("parties_individuals.party_id = parties_parties.id")) }
  scope :organizations, -> { where.exists(Parties::Organization.where("parties_organizations.party_id = parties_parties.id")) }
  scope :customers,     -> { where(relationship_to_institution_code: "customer") }

  # Public ID routing
  def to_param = public_id

  def self.find_by_public!(public_id)
    find_by!(public_id: public_id)
  end

  def self.find_by_profile!(profile_number)
    find_by!(profile_number: profile_number)
  end

  # --- Convenience -----------------------------------------------------------
  def person?       = individual.present?
  def organization? = organization.present?

  # Prefer the pointer; fall back to first preferred; then any name
  def display_name
    name = preferred_party_name || names.preferred.first || names.first
    name&.full_name.presence || "Party ##{id}"
  end

  # Optional sugar for creating with subtype
  def build_as_person(**attrs)       = (build_individual(**attrs); self)
  def build_as_organization(**attrs) = (build_organization(**attrs); self)

  # Clear a dangling pointer if needed (usually handled by Parties::Name)
  before_destroy :clear_preferred_pointer

  # Presentational: keep “Party” as the model name for routing/form builders
  def self.model_name = ActiveModel::Name.new(self, nil, "Party")

  private

  # Require exactly one subtype on create.
  # Controller ensures the selected subtype exists even if its fields are blank.
  def one_subtype_on_create
    count = [ individual, organization ].compact.size
    if count == 0
      errors.add(:base, "Select Person or Organization and provide required fields")
      # If you don’t want the extra noise, delete the two lines below:
      errors.add(:individual,   "can't be blank")
      errors.add(:organization, "can't be blank")
    elsif count > 1
      errors.add(:base, "Provide only one profile type (Person OR Organization)")
    end
  end

  # Prevent both being set on update/create (covers edits and param accidents)
  def prevent_both_subtypes
    return unless individual.present? && organization.present?
    errors.add(:base, "Provide only one profile type (Person OR Organization)")
  end

  def clear_preferred_pointer
    return unless preferred_party_name_id.present?
    # Avoid callbacks/validations on destroy; just null the pointer
    update_column(:preferred_party_name_id, nil)
  end
end
