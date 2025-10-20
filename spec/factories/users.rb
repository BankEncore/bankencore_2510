# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "ChangeMe_123!" }
    role_i { :read_only }
    trait(:confirmed)    { confirmed_at { Time.current } }
    trait(:staff)        { role_i { :staff } }
    trait(:system_admin) { role_i { :system_admin } }
  end
end
