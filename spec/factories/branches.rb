# spec/factories/branches.rb
FactoryBot.define do
  factory :branch do
    sequence(:code)  { |n| format("%03d", n) }
    name             { "Branch #{code}" }
    status           { "active" }
  end

  factory :branch_membership do
    association :user
    association :branch
  end
end
