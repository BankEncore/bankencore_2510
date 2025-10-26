# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email      { Faker::Internet.unique.email }
    password   { "ChangeMe123!" }
    first_name { "Test" }
    last_name  { "User" }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    # Full-access admin for policy specs
    trait :adminish do
      after(:create) do |u|
        # permissions
        p_read  = Permission.find_or_create_by!(key: "system.read")  { _1.name = "System Read" }
        p_write = Permission.find_or_create_by!(key: "system.write") { _1.name = "System Write" }
        p_admin = Permission.find_or_create_by!(key: "admin.access") { _1.name = "Admin Access" }

        # role
        role = Role.find_or_create_by!(key: "sysadmin") { _1.name = "Sysadmin" }

        # role ↔ permissions
        [ p_read, p_write, p_admin ].each do |perm|
          RolePermission.find_or_create_by!(role:, permission: perm)
        end

        # user ↔ role
        UserRole.find_or_create_by!(user: u, role:)
      end
    end
  end
end
