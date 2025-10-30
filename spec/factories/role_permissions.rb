# spec/factories/role_permissions.rb
FactoryBot.define do
  factory :role_permission do
    role
    permission
  end
end
