# spec/factories/system_naics_codes.rb
# new
FactoryBot.define do
  factory :system_naics_code, class: "System::NaicsCode" do
    version { "2022" }
    sequence(:code)  { |n| (511200 + n).to_s } # 5–6 digit
    sequence(:title) { |n| "NAICS #{n}" }
    level  { 5 }
    sector { code[0, 2] }
    active { true }

    trait :sector_level do
      level { 1 }
      code  { "51" }
      title { "Information" }
      sector { "51" }
    end

    trait :with_parent do
      parent_code { code[0..-2] } # naive parent
      level { 6 }
    end
  end
end
