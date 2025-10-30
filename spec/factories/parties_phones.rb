# spec/factories/parties_phones.rb
FactoryBot.define do
  sequence(:e164_seq) { |n| "+1415555#{format('%04d', n)}" }

  factory :parties_phone, class: "Parties::Phone" do
    association :party
    phone_type_code { "mobile" }
    e164            { generate(:e164_seq) }
    verified_at     { nil }
    preferred       { false }
    valid_from      { nil }
    valid_to        { nil }
    invalid_reason  { nil }

    trait :preferred do
      preferred { true }
    end
    trait :verified do
      verified_at { Time.current }
    end
  end
end
