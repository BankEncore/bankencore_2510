# spec/factories/parties_email_addresses.rb
FactoryBot.define do
  sequence(:email_seq) { |n| "user#{n}@example.test" }

  factory :parties_email_address, class: "Parties::EmailAddress" do
    association :party
    email_type_code { "primary" }
    email           { generate(:email_seq) }
    verified_at     { nil }
    preferred       { false }
    valid_from      { nil }
    valid_to        { nil }

    trait :preferred do
      preferred { true }
    end
    trait :verified do
      verified_at { Time.current }
    end
  end
end
