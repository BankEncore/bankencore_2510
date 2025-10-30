# app/models/parties/relationship.rb
class Parties::Relationship < ApplicationRecord
  self.table_name = "parties_relationships"
  belongs_to :source_party, class_name: "Parties::Party", foreign_key: :source_party_id, inverse_of: :outgoing_relationships
  belongs_to :target_party, class_name: "Parties::Party", foreign_key: :target_party_id, inverse_of: :incoming_relationships
end
