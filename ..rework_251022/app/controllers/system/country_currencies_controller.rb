class System::CountryCurrenciesController < ApplicationController
  include Pagy::Backend

  def index
    scope = policy_scope(System::CountryCurrency).includes(:country, :currency).order(:country_alpha2, :currency_code)
    scope = scope.where(country_alpha2: params[:country_alpha2].to_s.upcase) if params[:country_alpha2].present?
    scope = scope.where(currency_code:  params[:currency_code].to_s.upcase) if params[:currency_code].present?
    @pagy, @country_currencies = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  def show
    ca = params[:country_alpha2].to_s.upcase
    cc = params[:currency_code].to_s.upcase
    @country_currency = System::CountryCurrency.find_by!(country_alpha2: ca, currency_code: cc)
    authorize @country_currency
  end
end
