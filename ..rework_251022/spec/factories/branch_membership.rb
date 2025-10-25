# spec/factories/branch_memberships.rb
# new
FactoryBot.define do
  factory :branch_membership do
    association :user
    association :branch
  end
end
