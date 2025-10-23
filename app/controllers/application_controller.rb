# app/controllers/application_controller.rb
# new
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  def forbidden
    respond_to do |format|
      format.html { render file: Rails.public_path.join("403.html"), status: :forbidden, layout: false }
      format.turbo_stream { head :forbidden }
      format.any { head :forbidden }
    end
  end
end
