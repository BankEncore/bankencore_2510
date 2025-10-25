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

    trait :adminish do
      after(:create) do |u|
        %w[admin system_admin staff staff_admin superadmin].each do |key|
          role = Role.find_or_create_by!(key:) { |r| r.name = key.titleize }
          u.roles << role unless u.roles.exists?(role.id)
        end
      end
      after(:build) do |u|
        u.admin = true if u.respond_to?(:admin=)
        u.define_singleton_method(:admin?)        { true } unless u.respond_to?(:admin?)
        u.define_singleton_method(:system_admin?) { true } unless u.respond_to?(:system_admin?)
        u.define_singleton_method(:has_role?)     { |_k| true }
      end
    end
  end
end
