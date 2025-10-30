# spec/factories/parties_identities.rb
FactoryBot.define do
  sequence(:id_number_seq) { |n| "id#{n}abc" }

  factory :parties_identity, class: "Parties::Identity" do
    association :party
    identity_type_code { "passport" }
    number             { generate(:id_number_seq) }
    issuing_country    { "US" }
    system_region_id   { nil }
    issuer_name        { nil }
    issued_on          { nil }
    expires_on         { nil }
    metadata           { {} }
  end
end
