FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "ChangeMe_123!" }
    role { "user" }
    status { "active" }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :admin do
      role { "admin" }
    end
  end
end
