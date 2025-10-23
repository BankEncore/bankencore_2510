# app/controllers/base_controller.rb
class BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  around_action :use_time_zone

  # Enforce Pundit across non-index and index actions
  after_action :verify_authorized,     except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped,  only:   :index, unless: :skip_pundit?

  # 404s for missing records
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def skip_pundit?
    devise_controller?
  end

  def set_locale
    I18n.locale = current_user&.locale.presence || I18n.default_locale
  end

  def use_time_zone(&blk)
    tz = current_user&.time_zone.presence || "UTC"
    Time.use_zone(tz, &blk)
  end

  def not_found
    respond_to do |format|
      format.html { render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
      format.any  { head :not_found }
    end
  end

  # Devise strong params (adjust keys as needed)
  def configure_permitted_parameters
    keys = %i[first_name last_name display_name locale time_zone phone_e164]
    devise_parameter_sanitizer.permit(:sign_up,        keys: keys + %i[password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: keys + %i[password password_confirmation current_password])
  end
end
