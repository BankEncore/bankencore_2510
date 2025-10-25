# spec/factories/system_reference_lists.rb
FactoryBot.define do
  sequence(:ref_list_key)  { |n| "status_#{n}" }
  sequence(:ref_list_name) { |n| "Status values #{n}" }

  factory :system_reference_list, class: "System::ReferenceList" do
    key  { generate(:ref_list_key) }
    name { generate(:ref_list_name) }
  end
end
