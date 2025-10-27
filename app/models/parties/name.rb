# app/models/parties/name.rb
class Parties::Name < ApplicationRecord
  self.table_name = "parties_names"
  belongs_to :party
  validates :name_type_code, presence: true
  validates :preferred, inclusion: { in: [ true, false ] }
  validate  :single_preferred_per_party, if: :preferred?

  after_commit :bubble_to_party, if: :preferred?

  private
  def single_preferred_per_party
    if party.names.where(preferred: true).where.not(id: id).exists?
      errors.add(:preferred, "already set for this party")
    end
  end
  def bubble_to_party
    party.update_column(:preferred_party_name_id, id)
  end
end
