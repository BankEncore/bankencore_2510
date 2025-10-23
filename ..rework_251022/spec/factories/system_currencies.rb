# spec/factories/system_currencies.rb
# new
FactoryBot.define do
  factory :system_currency, class: "System::Currency" do
    code { "USD" }
    numeric { "840" }
    name { "US Dollar" }
    minor_units { 2 }
    symbol { "$" }
    active { true }
  end
end
