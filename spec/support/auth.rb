# spec/support/auth.rb
module AuthHelpers
  def login(user = create(:user, :system_admin))
    sign_in(user)
    user
  end
end

RSpec.configure { |c| c.include AuthHelpers, type: :request }
