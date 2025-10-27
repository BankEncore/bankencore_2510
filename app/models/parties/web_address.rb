# app/models/parties/web_address.rb
class Parties::WebAddress < ApplicationRecord
  self.table_name = "parties_web_addresses"
  belongs_to :party
end
