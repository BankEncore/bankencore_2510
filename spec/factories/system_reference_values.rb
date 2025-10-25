# spec/factories/system_reference_values.rb
FactoryBot.define do
  factory :system_reference_value, class: "System::ReferenceValue" do
    association :reference_list, factory: :system_reference_list
    code   { "A" }
    name   { "Active" }
    active { true }
  end
end
