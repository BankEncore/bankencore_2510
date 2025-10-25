# spec/support/auth_helpers.rb
module AuthHelpers
  def sign_in_admin
    user = create(:user, :system_admin)
    sign_in user, scope: :user
    user
  end
end
