# app/models/parties/relationship.rb
class Parties::Relationship < ApplicationRecord
  self.table_name = "parties_relationships"
  belongs_to :party
end
