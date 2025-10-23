# spec/factories/branches.rb
# new
FactoryBot.define do
  factory :branch do
    sequence(:code) { |n| format("%03d", n) }
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
    operating_hours do
      {
        tz: "America/New_York",
        weekly: [
          { day: "mon", open: "09:00", close: "17:00" },
          { day: "tue", open: "09:00", close: "17:00" },
          { day: "wed", open: "09:00", close: "17:00" },
          { day: "thu", open: "09:00", close: "17:00" },
          { day: "fri", open: "09:00", close: "17:00" }
        ],
        exceptions: []
      }
    end

    trait :inactive { status { 0 } }
    trait :pacific  { time_zone { "America/Los_Angeles" } }
  end
end
