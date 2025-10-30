# spec/factories/user_roles.rb
FactoryBot.define do
  factory :user_role do
    user
    role
  end
end
