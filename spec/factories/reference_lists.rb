# spec/factories/reference_lists.rb
FactoryBot.define do
  factory :system_reference_list, class: "System::ReferenceList" do
    public_id { SecureRandom.uuid }
    key       { "id_types_#{SecureRandom.uuid}" }   # unique, non-sequential
    name      { "ID Types" }

    # optional: deterministic override when needed
    trait :with_key do
      transient { forced_key { "custom_#{SecureRandom.hex(4)}" } }
      key { forced_key }
    end
  end
end
