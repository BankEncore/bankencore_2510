# spec/factories/system_reference_values.rb
# new
FactoryBot.define do
  factory :system_reference_value, class: "System::ReferenceValue" do
    association :reference_list, factory: :system_reference_list
    sequence(:code)  { |n| "code_#{n}" }
    sequence(:name)  { |n| "Reference Value #{n}" }
    short_name   { nil }
    description  { "Test reference value" }
    sort_index   { 50 }
    active       { true }
    external_code { nil }
    metadata     { {} }
    valid_from   { nil }
    valid_to     { nil }

    trait :inactive do
      active { false }
    end
  end
end
