# spec/factories/payments_ach_routings.rb
FactoryBot.define do
  sequence(:ach_rn) { |n| format("%09d", 200_000_000 + n) }

  factory :payments_ach_routing, class: "Payments::AchRouting" do
    sequence(:routing_number) { |n| format("%09d", 110000000 + n) }
    customer_name         { "X" }
    city                  { "PHL" }
    state_code            { "PA" }
    servicing_frb_number  { "031000040" }
    office_code           { "1" }
  end
end
