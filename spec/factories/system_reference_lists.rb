# spec/factories/system_reference_lists.rb
# new
FactoryBot.define do
  factory :system_reference_list, class: "System::ReferenceList" do
    sequence(:key)  { |n| "ref.list_#{n}" }
    sequence(:name) { |n| "Reference List #{n}" }
    description { "Test reference list" }
    active { true }
    metadata { {} }
  end
end
