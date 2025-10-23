# spec/factories/system_countries.rb
# new
FactoryBot.define do
  factory :system_country, class: "System::Country" do
    alpha2 { "US" }
    alpha3 { "USA" }
    numeric { "840" }
    iso_short_name { "United States of America" }
    dialing_prefix { "1" }
    postal_code_required { true }
    currency_primary_code { "USD" }
    active { true }

    trait :ca do
      alpha2 { "CA" } ; alpha3 { "CAN" } ; numeric { "124" }
      iso_short_name { "Canada" } ; dialing_prefix { "1" }
      currency_primary_code { "CAD" }
    end

    trait :fr do
      alpha2 { "FR" } ; alpha3 { "FRA" } ; numeric { "250" }
      iso_short_name { "France" } ; dialing_prefix { "33" }
      currency_primary_code { "EUR" }
    end
  end
end
