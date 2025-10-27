# spec/factories/parties.rb
FactoryBot.define do
  factory :party do
    relationship_to_institution_code { "customer" }
    established_on { Date.today }
  end

  factory :parties_name, class: "Parties::Name" do
    association :party
    name_type_code { "legal" }
    full_name { "Test Name" }
    preferred { false }
  end
end
