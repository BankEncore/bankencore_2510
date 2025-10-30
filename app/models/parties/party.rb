# app/models/parties/party.rb
class Parties::Party < ApplicationRecord
  self.table_name = "parties_parties" # use the actual table name

    has_one :individual,
    class_name: "Parties::Individual",
    foreign_key: :party_id,
    inverse_of: :party,
    dependent: :destroy

  has_one :organization,
    class_name: "Parties::Organization",
    foreign_key: :party_id,
    inverse_of: :party,
    dependent: :destroy

  has_many :names,           class_name: "Parties::Name",           foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :email_addresses, class_name: "Parties::EmailAddress",   foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :phones,          class_name: "Parties::Phone",          foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :postal_addresses, class_name: "Parties::PostalAddress",  foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :web_addresses,   class_name: "Parties::WebAddress",     foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :identities,      class_name: "Parties::Identity",       foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :tax_ids,         class_name: "Parties::TaxId",         foreign_key: :party_id, inverse_of: :party, dependent: :destroy
  has_many :disclosures,     class_name: "Parties::Disclosure",    foreign_key: :party_id, inverse_of: :party, dependent: :destroy

  has_many :outgoing_relationships, class_name: "Parties::Relationship",
           foreign_key: :source_party_id, inverse_of: :source_party, dependent: :destroy
  has_many :incoming_relationships, class_name: "Parties::Relationship",
           foreign_key: :target_party_id, inverse_of: :target_party, dependent: :destroy

  def self.model_name
    ActiveModel::Name.new(self, nil, "Party")
  end
end
