# spec/factories/system_regions.rb
# new
FactoryBot.define do
  factory :system_region, class: "System::Region" do
    association :country, factory: :system_country
    country_alpha2 { country.alpha2 }
    region_code { "AK" }
    name { "Alaska" }
    kind { "state" }
  end
end
