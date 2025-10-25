# app/controllers/admin/system/home_controller.rb
class Admin::System::HomeController < Admin::BaseController
  def index
    authorize(:admin_dashboard, :index?)
    redirect_to admin_root_path
  end
end
