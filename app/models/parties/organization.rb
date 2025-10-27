# app/models/parties/organization.rb
class Parties::Organization < ApplicationRecord
  self.table_name = "parties_organizations"
  belongs_to :party
  validates :party_id, uniqueness: true
end
