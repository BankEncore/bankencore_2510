# spec/support/devise_controller_mapping.rb
# Ensure controller specs that bypass routing have a Devise mapping available.
RSpec.configure do |config|
  config.before(:each, type: :controller) do
    if defined?(Devise) && respond_to?(:request) && request
      request.env['devise.mapping'] ||= Devise.mappings[:user]
    end
  end
end
