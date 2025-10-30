# spec/factories/parties_web_addresses.rb
FactoryBot.define do
  sequence(:url_seq) { |n| "https://example#{n}.test" }

  factory :parties_web_address, class: "Parties::WebAddress" do
    association :party
    url        { generate(:url_seq) }
    preferred  { false }
    valid_from { nil }
    valid_to   { nil }

    trait :preferred do
      preferred { true }
    end
  end
end
