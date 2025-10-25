# app/controllers/admin/home_controller.rb
# new
class Admin::HomeController < Admin::BaseController
  def index
    authorize(:admin_dashboard, :index?)
    redirect_to admin_root_path
  end
end
