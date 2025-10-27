# app/models/parties/individual.rb
class Parties::Individual < ApplicationRecord
  self.table_name = "parties_individuals"
  belongs_to :party
  validates :party_id, uniqueness: true
end
