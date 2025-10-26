# spec/factories/branches.rb
FactoryBot.define do
  factory :branch do
    sequence(:code) { |n| "BR#{n}" }
    name { "Test Branch" }
    status { 1 }
    time_zone { "America/New_York" }
    address_1 { "1 Test Way" }
    city { "Pittsburgh" }
    region_code { "PA" }
    postal_code { "15222" }
    country_alpha2 { "US" }
    phone { "+1 412 555 0123" }
    email { "branch@test.local" }

    # valid hours
    operating_hours do
      {
        "mon" => { "open" => "09:00", "close" => "17:00" },
        "tue" => { "open" => "09:00", "close" => "17:00" },
        "wed" => { "open" => "09:00", "close" => "17:00" },
        "thu" => { "open" => "09:00", "close" => "17:00" },
        "fri" => { "open" => "09:00", "close" => "17:00" }
      }
    end

    trait :no_hours do
      operating_hours { {} }  # skips time parsing
    end

    trait :inactive do
      status { 0 }
    end
  end
end
