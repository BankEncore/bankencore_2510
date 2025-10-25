# spec/factories/permissions.rb
# new
FactoryBot.define do
  factory :permission do
    sequence(:key)  { |n| "perm_#{n}" }
    sequence(:name) { |n| "Permission #{n}" }

    trait(:admin_access) { key { "admin.access" } name { "Admin access" } }
  end
end
