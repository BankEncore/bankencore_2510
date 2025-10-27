# app/models/parties/postal_address.rb
class Parties::PostalAddress < ApplicationRecord
  self.table_name = "parties_postal_addresses"
  belongs_to :party
end
