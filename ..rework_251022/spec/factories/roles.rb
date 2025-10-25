# spec/factories/roles.rb
# new
FactoryBot.define do
  factory :role do
    sequence(:key)  { |n| "role_#{n}" }
    sequence(:name) { |n| "Role #{n}" }

    trait :viewer  { key { "viewer" }  name { "Read-only access" } }
    trait :staff   { key { "staff" }   name { "Standard staff" } }
    trait :admin   { key { "system_admin" } name { "Full admin" } }
  end
end
