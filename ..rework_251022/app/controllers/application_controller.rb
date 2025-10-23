# app/controllers/application_controller.rb
# new
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  private def forbidden = render file: Rails.root.join("public/403.html"), status: :forbidden, layout: false
end
