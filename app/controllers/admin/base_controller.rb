# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  private

  def authorize_admin!
    return if current_user&.role == "admin"
    head :forbidden
  end
end