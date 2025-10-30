# spec/factories/roles.rb
FactoryBot.define do
  factory :role do
    sequence(:key) { |n| "role#{n}" }

    trait :sysadmin do
      key { "sysadmin" }
    end
  end
end
