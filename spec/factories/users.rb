# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password  { "Password!1" }
    time_zone { "UTC" }
    role      { "user" }
    role_i    { "read_only" }
    status    { "active" }
    admin     { false }

    trait :confirmed do
      after(:build) { |u| u.confirmed_at = Time.current if u.respond_to?(:confirmed_at=) }
    end

    trait :staff do
      role_i { "staff" }
    end

    trait :system_admin do
      role_i { "system_admin" }
      admin  { true }
    end

    trait :admin do
      admin { true }
    end
  end
end
