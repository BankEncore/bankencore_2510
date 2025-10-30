# spec/factories/permissions.rb
FactoryBot.define do
  factory :permission do
    sequence(:key) { |n| "perm.#{n}" }

    trait :admin_access do
      key { "admin.access" }
    end
  end
end
