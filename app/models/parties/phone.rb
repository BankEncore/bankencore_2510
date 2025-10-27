# app/models/parties/phone.rb
class Parties::Phone < ApplicationRecord
  self.table_name = "parties_phones"
  belongs_to :party
  validates :phone_type_code, presence: true
end
