# spec/integration/reference_values_db_spec.rb
require "rails_helper"

RSpec.describe "DB constraints" do
  it "has FK to system_reference_lists" do
    fks = ActiveRecord::Base.connection.foreign_keys("system_reference_values")
    names = fks.map(&:to_table)
    expect(names).to include("system_reference_lists")
  end

  it "enforces NOT NULL on reference_list_id" do
    null_ok = ActiveRecord::Base.connection.columns("system_reference_values")
                 .find { |c| c.name == "reference_list_id" }&.null
    expect(null_ok).to be(false)
  end
end
