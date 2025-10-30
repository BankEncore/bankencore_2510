# app/models/parties/name.rb
class Parties::Name < ApplicationRecord
  self.table_name = "parties_names"

  belongs_to :party, class_name: "Parties::Party", inverse_of: :names

  # Required fields
  validates :name_type_code, presence: true
  validates :preferred, inclusion: { in: [ true, false ] }

  # UX-friendly guard (DB also has UNIQUE (party_id) WHERE preferred)
  validate :single_preferred_per_party, if: :will_be_preferred?

  # Keep parties_parties.preferred_party_name_id in sync
  after_commit :apply_preferred_pointer, if: :saved_change_to_preferred?

  # Scopes
  scope :preferred, -> { where(preferred: true) }

  private

  def will_be_preferred?
    preferred_changed = will_save_change_to_preferred?
    preferred_changed ? self.preferred : self.preferred?
  end

  def single_preferred_per_party
    if party.names.where(preferred: true).where.not(id: id).exists?
      errors.add(:preferred, "already set for this party")
    end
  end

  def apply_preferred_pointer
    if preferred
      # point party to this name
      party.update_column(:preferred_party_name_id, id)
    else
      # if this was the pointer, clear it
      if party.preferred_party_name_id == id
        party.update_column(:preferred_party_name_id, nil)
      end
    end
  end
end
