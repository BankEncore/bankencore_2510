# spec/support/devise.rb
module AuthHelpers
  def sign_in_confirmed(user = create(:user, :confirmed))
    sign_in user
    user
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
  config.include AuthHelpers, type: :system
end