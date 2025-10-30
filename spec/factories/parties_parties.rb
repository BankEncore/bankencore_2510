# spec/factories/parties_parties.rb
FactoryBot.define do
  factory :parties_party, class: "Parties::Party" do
    profile_number { "1000000001" }
    relationship_to_institution_code { "customer" }
    established_on { Date.current }
  end
end
