# spec/factories/payments_ach_routings.rb
FactoryBot.define do
  factory :payments_ach_routing, class: "Payments::AchRouting" do
    routing_number        { "031000040" }
    new_routing_number    { "000000000" }
    customer_name         { "Test Bank" }
    address               { "1 Main St" }
    city                  { "Philadelphia" }
    state_code            { "PA" }
    zip_code              { "19106" }
    phone_number          { "2155746000" }
    servicing_frb_number  { "031000040" }
    office_code           { "O" }
    record_type_code      { "0" }
    institution_status_code { "1" }
    data_view_code        { "1" }
    us_treasury           { false }
    us_postal_service     { false }
    federal_reserve_bank  { false }
    on_us                 { false }
    special_handling      { false }
    notes                 { "" }
  end
end
