# spec/factories/party.rb
FactoryBot.define do
  sequence(:party_profile_number) { |n| format("%08d%02d", n + 100_000_00, Time.now.year % 100) }
  sequence(:uuid) { SecureRandom.uuid }

  factory :party, class: "Parties::Party" do
    public_id           { generate(:uuid) }
    profile_number      { generate(:party_profile_number) }
    relationship_to_institution_code { "customer" }
    established_on      { Date.current }
    withholding_option_code { nil }

    trait :with_preferred_name do
      after(:create) do |p|
        create(:parties_name, party: p, preferred: true, name_type_code: "legal", full_name: "Test Party")
        p.update_column(:preferred_party_name_id, p.names.preferred.pick(:id))
      end
    end
  end
end
