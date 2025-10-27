# app/models/parties/email_address.rb
class Parties::EmailAddress < ApplicationRecord
  self.table_name = "parties_email_addresses"
  belongs_to :party
  validates :email, format: URI::MailTo::EMAIL_REGEXP, allow_blank: true
end
