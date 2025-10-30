# app/controllers/home_controller.rb
class HomeController < ApplicationController
  skip_after_action :verify_authorized, only: :forbidden
  skip_after_action :verify_policy_scoped, only: :forbidden

  def forbidden
    respond_to do |format|
      format.html { render file: Rails.public_path.join("403.html"), status: :forbidden, layout: false }
      format.turbo_stream { head :forbidden }
      format.any { head :forbidden }
    end
  end
end
