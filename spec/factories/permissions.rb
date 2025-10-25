# spec/factories/permissions.rb
FactoryBot.define do
  factory :permission do
    sequence(:key)  { |n| "perm_#{n}" }
    sequence(:name) { |n| "Permission #{n}" }

    trait :admin_access do
      key  { "admin.access" }
      name { "Admin access" }
    end
  end
end
