# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password     { "ChangeMe123!" }
    first_name   { "Test" }
    last_name    { "User" }

    # used by many specs
    trait :confirmed do
      confirmed_at { Time.current }             # Devise confirmable-friendly
    end

    # legacy admin wiring used across specs
    trait :adminish do
      confirmed                                 # most specs expect confirmed admins
      after(:create) do |u|
        p_admin = Permission.find_or_create_by!(key: "admin.access") { _1.name = "Admin access" }
        p_read  = Permission.find_or_create_by!(key: "system.read")  { _1.name = "System read" }
        p_write = Permission.find_or_create_by!(key: "system.write") { _1.name = "System write" }
        role    = Role.find_or_create_by!(key: "sysadmin")           { _1.name = "Sysadmin" }
        [ p_admin, p_read, p_write ].each { |perm| RolePermission.find_or_create_by!(role:, permission: perm) }
        UserRole.find_or_create_by!(user: u, role:)
      end
    end

    # alias used by newer specs
    trait :system_admin do
      adminish
    end
  end
end
