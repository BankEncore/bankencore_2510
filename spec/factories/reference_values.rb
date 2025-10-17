FactoryBot.define do
  factory :system_reference_value, class: "System::ReferenceValue" do
    association :reference_list, factory: :system_reference_list
    public_id { SecureRandom.uuid }
    key { "military_id" }
    label { "U.S. Uniformed Services ID/CAC" }
    # keep :position only if the column exists; otherwise drop it
    # position { 0 }
    # remove :active unless the column exists
  end
end
