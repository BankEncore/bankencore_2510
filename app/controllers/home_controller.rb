# app/controllers/admin/system/home_controller.rb
# new
class HomeController < ApplicationController
  def index
    # If user is not signed in, redirect to the Devise sign-in page.
    # Use the Devise route helper rather than routing-time constraints.
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end
end
