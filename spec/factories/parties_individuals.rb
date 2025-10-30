# spec/factories/parties_individuals.rb
FactoryBot.define do
  factory :parties_individual, class: "Parties::Individual" do
    association :party
    residence_country      { "US" }
    birth_date             { nil }
    gender_code            { nil }
    marital_status_code    { nil }
    immigration_status_code { nil }
    education_level_code   { nil }
    home_ownership_code    { nil }
    race_code              { nil }
    employment_type_code   { nil }
    occupation_code        { nil }
  end
end
