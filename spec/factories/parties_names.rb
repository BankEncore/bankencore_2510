# spec/factories/parties_names.rb
FactoryBot.define do
  sequence(:full_name_seq) { |n| "Full Name #{n}" }

  factory :parties_name, class: "Parties::Name" do
    association :party
    name_type_code { "legal" }
    full_name      { generate(:full_name_seq) }
    family_name    { nil }
    given_name     { nil }
    middle_name    { nil }
    prefix_code    { nil }
    suffix_code    { nil }
    preferred      { false }
    valid_from     { nil }
    valid_to       { nil }

    trait :preferred do
      preferred { true }
    end
  end
end
