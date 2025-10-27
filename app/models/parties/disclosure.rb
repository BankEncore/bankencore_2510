# app/models/parties/disclosure.rb
class Parties::Disclosure < ApplicationRecord
  self.table_name = "parties_disclosures"
  belongs_to :party
end
