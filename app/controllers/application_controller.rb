# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # after_action :verify_authorized, unless: :skip_pundit?
  # after_action :verify_policy_scoped, if: :pundit_index_action?, unless: :skip_pundit?

  after_action :verify_authorized,    except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only:   :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :redirect_forbidden

  def forbidden
    respond_to do |format|
      format.html { render file: Rails.public_path.join("403.html"), status: :forbidden, layout: false }
      format.turbo_stream { head :forbidden }
      format.any { head :forbidden }
    end
  end

  private

  def redirect_forbidden = redirect_to forbidden_path

  # Skip for Devise, Home#index, and the forbidden action.
  def skip_pundit?
    devise_controller? || controller_path == "home" || action_name == "forbidden"
  end

  def pundit_index_action? = action_name == "index"
end
