# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password   { "ChangeMe123!" }
    first_name { "Test" }
    last_name  { "User" }

    # ---- Test-only policy predicate shim ----
    transient do
      policy_roles { [] } # e.g., %i[system_admin staff]
    end

    after(:build) do |u, e|
      %i[system_admin staff onboarding operations].each do |name|
        next if u.respond_to?("#{name}?")

        u.define_singleton_method("#{name}?") do
          return true if e.policy_roles.map(&:to_sym).include?(name)
          has_admin_perm = respond_to?(:can?) && can?("admin.access")
          has_role = respond_to?(:roles) && roles.where(key: {
            system_admin: "sysadmin",
            staff:        "staff",
            onboarding:   "onboarding",
            operations:   "operations"
          }[name]).exists?
          name == :system_admin ? (has_admin_perm || has_role) : has_role
        end
      end
    end
    # -----------------------------------------

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :adminish do
      confirmed
      after(:create) do |u|
        p_admin = Permission.find_or_create_by!(key: "admin.access") { _1.name = "Admin access" }
        p_read  = Permission.find_or_create_by!(key: "system.read")  { _1.name = "System read" }
        p_write = Permission.find_or_create_by!(key: "system.write") { _1.name = "System write" }
        role    = Role.find_or_create_by!(key: "sysadmin")           { _1.name = "Sysadmin" }
        [ p_admin, p_read, p_write ].each { |perm| RolePermission.find_or_create_by!(role:, permission: perm) }
        UserRole.find_or_create_by!(user: u, role:)
      end
    end

    trait :system_admin do
      adminish
      policy_roles { [ :system_admin ] }
    end

    trait :staff do
      confirmed
      after(:create) do |u|
        role = Role.find_or_create_by!(key: "staff") { _1.name = "Staff" }
        UserRole.find_or_create_by!(user: u, role:)
      end
    end

    trait :onboarding do
      confirmed
      after(:create) do |u|
        role = Role.find_or_create_by!(key: "onboarding") { _1.name = "Onboarding" }
        UserRole.find_or_create_by!(user: u, role:)
      end
    end

    trait :operations do
      confirmed
      after(:create) do |u|
        role = Role.find_or_create_by!(key: "operations") { _1.name = "Operations" }
        UserRole.find_or_create_by!(user: u, role:)
      end
    end

    trait :with_admin_access do
      after(:create) do |u|
        role = Role.find_or_create_by!(key: "sysadmin")
        perm = Permission.find_or_create_by!(key: "admin.access")
        RolePermission.find_or_create_by!(role:, permission: perm)
        UserRole.find_or_create_by!(user: u, role:)
      end
    end
  end
end
