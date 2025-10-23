# spec/factories/role_permission.rb
# new
FactoryBot.define do
  factory :role_permission do
    association :role
    association :permission
  end
end
