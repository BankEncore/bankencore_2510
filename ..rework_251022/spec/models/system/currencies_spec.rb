# spec/models/system/currency_spec.rb
# new
require "rails_helper"

RSpec.describe System::Currency, type: :model do
  subject do
    described_class.new(
      code: "usd",
      numeric: "84",
      name: "US Dollar",
      minor_units: 2,
      symbol: "$",
      unicode_codepoint: 36,
      active: true
    )
  end

  it "is valid with minimal required attributes" do
    expect(subject).to be_valid
  end

  describe "normalization" do
    it "uppercases code and zero-pads numeric" do
      subject.validate
      expect(subject.code).to eq("USD")
      expect(subject.numeric).to eq("084")
    end

    it "keeps three-digit numeric unchanged" do
      c = described_class.new(code: "eur", numeric: "978", name: "Euro", minor_units: 2)
      c.validate
      expect(c.numeric).to eq("978")
      expect(c.code).to eq("EUR")
    end
  end

  describe "validations" do
    it "requires 3-letter code and 3-digit numeric" do
      subject.code = "US"
      expect(subject).to be_invalid
      subject.code = "USDX"
      expect(subject).to be_invalid
      subject.code = "USD"

      subject.numeric = "97"
      expect(subject).to be_invalid
      subject.numeric = "0978"
      expect(subject).to be_invalid
      subject.numeric = "978"
      expect(subject).to be_valid
    end

    it "enforces uniqueness on code and numeric" do
      described_class.create!(code: "USD", numeric: "840", name: "US Dollar", minor_units: 2)
      dup = described_class.new(code: "usd", numeric: "840", name: "Duplicate", minor_units: 2)
      expect(dup).to be_invalid # model-level uniqueness (code case-insensitive)
    end

    it "limits minor_units to 0..3" do
      subject.minor_units = -1
      expect(subject).to be_invalid
      subject.minor_units = 4
      expect(subject).to be_invalid
      subject.minor_units = 3
      expect(subject).to be_valid
    end

    it "limits symbol length and unicode_codepoint range" do
      subject.symbol = "TOO-LONG" * 2
      expect(subject).to be_invalid
      subject.symbol = "$"
      subject.unicode_codepoint = 0
      expect(subject).to be_invalid
      subject.unicode_codepoint = 0x110000
      expect(subject).to be_invalid
      subject.unicode_codepoint = 0x20AC
      expect(subject).to be_valid
    end
  end

  describe "scopes" do
    before do
      described_class.create!(code: "USD", numeric: "840", name: "US Dollar", minor_units: 2, active: true)
      described_class.create!(code: "CAD", numeric: "124", name: "Canadian Dollar", minor_units: 2, active: false)
    end

    it ".active returns only active currencies" do
      expect(described_class.active.pluck(:code)).to match_array(%w[USD])
    end

    it ".by_code finds by alpha code (case-insensitive)" do
      expect(described_class.by_code("usd").pick(:numeric)).to eq("840")
    end

    it ".by_numeric finds by numeric code with padding" do
      expect(described_class.by_numeric(124).pick(:code)).to eq("CAD")
      expect(described_class.by_numeric("124").pick(:code)).to eq("CAD")
    end
  end

  describe "#unicode_hex" do
    it "returns U+XXXX string when codepoint present" do
      expect(subject.unicode_hex).to eq("U+0024")
      subject.unicode_codepoint = 0x20AC
      expect(subject.unicode_hex).to eq("U+20AC")
    end
  end

  describe "#display_name" do
    it "returns 'Name (CODE)'" do
      subject.validate
      expect(subject.display_name).to eq("US Dollar (USD)")
    end
  end
end
