# app/controllers/admin/base_controller.rb
module Admin
  class BaseController < ApplicationController
    layout "admin"
    before_action :authenticate_user!
    before_action :authorize_admin!

    private

    def require_admin!
      # replace with your real check
      head :forbidden unless current_user&.respond_to?(:admin?) && current_user.admin?
    end

    def authorize_admin! = head(:forbidden) unless current_user&.role == "admin"

  end
end
