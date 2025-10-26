# spec/factories/branch_memberships.rb
FactoryBot.define do
  factory :branch_membership do
    association :branch, factory: [:branch, :no_hours], strategy: :create
    association :user, strategy: :create
  end
end
