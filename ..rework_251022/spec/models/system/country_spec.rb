# spec/models/system/country_spec.rb
# new
require "rails_helper"

RSpec.describe System::Country, type: :model do
  subject do
    described_class.new(
      alpha2: "US", alpha3: "USA", numeric: "840",
      iso_short_name: "United States of America",
      dialing_prefix: "1", postal_code_required: true,
      currency_primary_code: "USD"
    )
  end

  it { is_expected.to be_valid }

  it "validates ISO formats" do
    subject.alpha2 = "U" ; expect(subject).to be_invalid
    subject.alpha2 = "USA"; expect(subject).to be_invalid
    subject.alpha2 = "US"

    subject.alpha3 = "US";  expect(subject).to be_invalid
    subject.alpha3 = "USA"; expect(subject).to be_valid

    subject.numeric = "84";  expect(subject).to be_invalid
    subject.numeric = "840"; expect(subject).to be_valid
  end

  it "requires unique ISO codes" do
    described_class.create!(subject.attributes)
    dup = described_class.new(subject.attributes)
    expect(dup).to be_invalid
  end

  it "accepts optional postal code regex" do
    subject.postal_code_regex = '^\d{5}(-\d{4})?$'
    expect(subject).to be_valid
  end
end
