# app/controllers/system/currencies_controller.rb
# new
class System::CurrenciesController < ApplicationController
  include Pagy::Backend

  # GET /system/currencies
  def index
    scope = policy_scope(System::Currency).where(active: true).order(:code)
    if (q = params[:q].to_s.strip.presence)
      ilike = "%#{q}%"
      scope = scope.where("code ILIKE ? OR name ILIKE ? OR full_name ILIKE ?", ilike, ilike, ilike)
    end
    @pagy, @currencies = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /system/currencies/:code
  def show
    @currency = System::Currency.find_by!(code: params[:code].to_s.upcase)
    authorize @currency
  end
end
