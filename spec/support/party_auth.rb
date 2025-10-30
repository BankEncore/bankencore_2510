# spec/support/party_auth.rb
RSpec.shared_context "as_admin" do
  let(:user) { create(:user, :system_admin, :confirmed) }
  before { login_as(user, scope: :user) }
end
