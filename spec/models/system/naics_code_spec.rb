require "rails_helper"

RSpec.describe System::NaicsCode, type: :model do
  it "persists with required version and level" do
    n = described_class.create!(version: "2022", code: "31", title: "Manufacturing", level: 2)
    expect(n.level).to eq(2)
    expect(n.version).to eq("2022")
  end

  it "enforces (version, code) uniqueness" do
    create(:system_naics_code, version: "2022", code: "311", title: "Food", level: 3)
    dup = build(:system_naics_code, version: "2022", code: "311", title: "Food 2", level: 3)
    expect(dup).not_to be_valid
  end

  it "links parent by prefix within same version" do
    p = create(:system_naics_code, version: "2022", code: "31",  title: "Manuf", level: 2)
    c = create(:system_naics_code, version: "2022", code: "311", title: "Food",  level: 3, parent_code: "31")
    if c.respond_to?(:parent)
      expect(c.parent).to eq(p)
    else
      expect(c.parent_code).to eq(p.code)
    end
  end
end
