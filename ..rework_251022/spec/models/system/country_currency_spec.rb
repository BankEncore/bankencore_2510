# spec/models/system/country_currency_spec.rb
# new
require "rails_helper"

RSpec.describe System::CountryCurrency, type: :model do
  let!(:country)  { System::Country.create!(alpha2: "US", alpha3: "USA", numeric: "840", iso_short_name: "United States of America") }
  let!(:currency) { System::Currency.create!(code: "USD", name: "US Dollar", numeric: "840", minor_units: 2) }

  it "validates basic join" do
    link = described_class.new(country_alpha2: "US", currency_code: "USD", is_primary: true, legal_tender: true)
    expect(link).to be_valid
  end

  it "prevents duplicates (country, currency)" do
    described_class.create!(country_alpha2: "US", currency_code: "USD")
    dup = described_class.new(country_alpha2: "US", currency_code: "USD")
    expect { dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique).or change { dup.valid? }.to(false)
  end

  it "enforces valid date window" do
    bad = described_class.new(country_alpha2: "US", currency_code: "USD", valid_from: Date.new(2025,1,2), valid_to: Date.new(2025,1,1))
    expect { bad.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
  end
end
