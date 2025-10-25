# app/controllers/admin/base_controller.rb
# new
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  after_action :verify_authorized
  private
  def authorize_admin!
    authorize(:system_admin, :access?)
  end
end
