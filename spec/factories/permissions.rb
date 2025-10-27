# spec/factories/permissions.rb
FactoryBot.define do
  factory :permission do
    key  { "system.read" }
    name { "System read" }
  end
end
