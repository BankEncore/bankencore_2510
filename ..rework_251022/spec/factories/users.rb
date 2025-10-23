# spec/factories/users.rb
# new
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "ChangeMe123!" }
    first_name { "Ada" }
    last_name  { "Lovelace" }
    time_zone  { "America/New_York" }
    confirmed_at { Time.current }

    trait :viewer do
      after(:create) { |u| u.roles << Role.find_or_create_by!(key: "viewer", name: "Read-only access") }
    end

    trait :staff do
      after(:create) { |u| u.roles << Role.find_or_create_by!(key: "staff", name: "Standard staff") }
    end

    trait :system_admin do
      after(:create) do |u|
        r = Role.find_or_create_by!(key: "system_admin", name: "Full admin")
        p = Permission.find_or_create_by!(key: "admin.access", name: "Admin access")
        RolePermission.find_or_create_by!(role: r, permission: p)
        u.roles << r
      end
    end
  end
end
