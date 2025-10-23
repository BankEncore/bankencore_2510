# spec/factories/user_roles.rb
# new
FactoryBot.define do
  factory :user_role do
    association :user
    association :role
  end
end
