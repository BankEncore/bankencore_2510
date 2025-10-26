# spec/views/home/index.html.erb_spec.rb
require "rails_helper"

RSpec.describe "home/index", type: :view do
  it "renders title and hero" do
    render              # renders the view WITHOUT the layout
    expect(rendered).to include("BankEncore")
    expect(rendered).to include("hero")
  end
end
