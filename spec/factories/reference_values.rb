# spec/factories/reference_values.rb
FactoryBot.define do
  factory :system_reference_value, class: "System::ReferenceValue" do
    association :reference_list, factory: :system_reference_list

    sequence(:key)   { |n| "val_#{n}" }     # REQUIRED
    sequence(:code)  { |n| "VAL#{n}" }      # keep if your model has it

    transient { text { "Value" } }

    after(:build) do |v, ev|
      v.public_id ||= SecureRandom.uuid if v.respond_to?(:public_id=)
      v.position   = 1                  if v.respond_to?(:position=)
      v.active     = true               if v.respond_to?(:active=)
      if v.respond_to?(:label=)
        v.label = ev.text
      elsif v.respond_to?(:name=)
        v.name  = ev.text
      end
    end
  end
end
