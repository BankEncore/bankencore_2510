# spec/support/auth_helpers.rb
module AuthHelpers
  def sign_in_confirmed(user = create(:user, :confirmed))
    sign_in user
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request   # add :system if you use it there too
end
