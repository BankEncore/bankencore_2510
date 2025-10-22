# app/controllers/admin/system/country_currencies_controller.rb
class Admin::System::CountryCurrenciesController < Admin::BaseController
  include Pagy::Backend
  before_action :set_country_currency, only: %i[show edit update destroy]
  before_action :load_collections,     only: %i[new edit create update]


  def index
    authorize ::System::CountryCurrency

    @countries  = ::System::Country.order(:name).select(:id, :name)
    @currencies = ::System::Currency.order(:code).select(:id, :code, :name)

    scope = policy_scope(::System::CountryCurrency).includes(:country, :currency)
    scope = scope.where(country_id: params[:country_id])   if params[:country_id].present?
    scope = scope.where(currency_id: params[:currency_id]) if params[:currency_id].present?

    @pagy, @country_currencies = pagy(scope.order(:country_id, :currency_id), items: (params[:items] || 50))
  end

  def show    ; authorize @country_currency end
  def new     ; @country_currency = ::System::CountryCurrency.new; authorize @country_currency end
  def edit    ; authorize @country_currency end

  def create
    @country_currency = ::System::CountryCurrency.new(country_currency_params)
    authorize @country_currency
    if @country_currency.save
      redirect_to admin_system_country_currencies_path, notice: "Created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @country_currency
    if @country_currency.update(country_currency_params)
      redirect_to admin_system_country_currencies_path, notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @country_currency
    @country_currency.destroy!
    redirect_to admin_system_country_currencies_path, notice: "Deleted"
  end

  private

  def set_country_currency
    id = params[:public_id] || params[:id]
    @country_currency = ::System::CountryCurrency.find_by!(public_id: id)
  end

  def country_currency_params
    params.require(:system_country_currency).permit(:country_id, :currency_id, :default_for_country, :valid_from, :valid_to)
  end

  def load_collections
    @countries  = ::System::Country.order(:name).select(:id, :name)
    @currencies = ::System::Currency.order(:code).select(:id, :code, :name)
  end
end
