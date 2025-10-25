FactoryBot.define do
  factory :system_naics_code, class: "System::NaicsCode" do
    version { "2022" }
    code    { "311" }
    title   { "Food" }
    level   { 3 }
  end
end
