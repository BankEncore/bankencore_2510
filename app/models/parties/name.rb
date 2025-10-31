# app/models/parties/name.rb
class Parties::Name < ApplicationRecord
  self.table_name = "parties_names"

  belongs_to :party, class_name: "Parties::Party", inverse_of: :names

  # --- Validations -----------------------------------------------------------
  validates :name_type_code, presence: true
  validates :preferred, inclusion: { in: [ true, false ] }
  validate  :single_preferred_per_party, if: :will_be_preferred?
  validate  :valid_range
  validate  :person_requires_given_and_family, if: :person?

  # --- Derivation / Normalization -------------------------------------------
  # For people, derive full_name from parts. For organizations, never clobber.
  before_validation :autofill_full_name_for_person

  # --- Pointer sync (you already had this) -----------------------------------
  after_commit :apply_preferred_pointer, if: :saved_change_to_preferred?
  after_destroy_commit :repoint_after_destroy

  # --- Scopes ----------------------------------------------------------------
  scope :preferred, -> { where(preferred: true) }

  before_validation :populate_full_name, if: -> { full_name.blank? }

  after_commit :sync_party_preferred_pointer

  # --- Helpers ---------------------------------------------------------------
  def person?
    party&.individual.present?
  end

  def compose_person_full_name
    fam   = family_name.to_s.strip
    given = given_name.to_s.strip
    mid   = middle_name.to_s.strip
    pre   = prefix_code.to_s.strip
    suf   = suffix_code.to_s.strip

    core = if mid.present?
      "#{fam}, #{given} #{mid.first}."
    else
      "#{fam}, #{given}"
    end

    core = "#{pre} #{core}" if pre.present?
    core = "#{core}, #{suf}" if suf.present?
    core
  end

  private

  # --- Validation helpers ----------------------------------------------------
  def will_be_preferred?
    will_save_change_to_preferred? ? preferred : preferred?
  end

  def single_preferred_per_party
    if party&.names&.where(preferred: true)&.where.not(id: id)&.exists?
      errors.add(:preferred, "already set for this party")
    end
  end

  def valid_range
    return if valid_from.blank? || valid_to.blank?
    errors.add(:valid_to, "must be on/after valid_from") if valid_to < valid_from
  end

  def person_requires_given_and_family
    if given_name.blank? || family_name.blank?
      errors.add(:base, "Given and family names are required for individual profiles")
    end
  end

  # --- Derivation ------------------------------------------------------------
  def autofill_full_name_for_person
    return unless person?
    return if given_name.blank? || family_name.blank?
    self.full_name = compose_person_full_name
  end

  # --- Pointer sync + edges --------------------------------------------------
  def apply_preferred_pointer
    # Use update_columns to avoid callbacks/validations and infinite loops.
    if preferred
      party.update_columns(preferred_party_name_id: id)
    else
      party.update_columns(preferred_party_name_id: nil) if party.preferred_party_name_id == id
    end
  end

  def repoint_after_destroy
    return unless party&.preferred_party_name_id == id
    replacement_id = party.names.preferred.order(updated_at: :desc).pick(:id)
    party.update_columns(preferred_party_name_id: replacement_id) # may be nil
  end
end
