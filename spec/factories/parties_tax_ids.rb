# spec/factories/parties_tax_ids.rb
FactoryBot.define do
  factory :parties_tax_id, class: "Parties::TaxId" do
    association :party, factory: :parties_party
    tax_id_type_code { "ein" }
    value            { generate(:ein_seq) }
    country          { "US" }

    trait :non_us do
      country { "CA" }
      tax_id_type_code { "bn" }
      value { "abc12345" }
      w8_signed_on { nil }
    end
  end
end
