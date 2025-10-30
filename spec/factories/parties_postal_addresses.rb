# spec/factories/parties_postal_addresses.rb
FactoryBot.define do
  factory :parties_postal_address, class: "Parties::PostalAddress" do
    association :party
    address_use_code  { "primary" }
    address_type_code { "home" }
    line1             { "1 Main St" }
    line2             { nil }
    city              { "PHL" }
    system_region_id  { nil }
    postal_code       { "19103" }
    country           { "US" }
    preferred         { false }
    valid_from        { nil }
    valid_to          { nil }

    trait :preferred do
      preferred { true }
    end
  end
end
