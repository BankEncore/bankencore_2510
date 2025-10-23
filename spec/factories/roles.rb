# spec/factories/roles.rb
# new
FactoryBot.define do
  factory :role do
    sequence(:key)  { |n| "role_#{n}" }
    sequence(:name) { |n| "Role #{n}" }

    trait :viewer do
      key  { "viewer" }
      name { "Read-only access" }
    end

    trait :staff do
      key  { "staff" }
      name { "Standard staff" }
    end

    trait :admin do
      key  { "system_admin" }
      name { "Full admin" }
    end
  end
end
