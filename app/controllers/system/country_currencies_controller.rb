# app/controllers/system/country_currencies_controller.rb
class System::CountryCurrenciesController < ApplicationController
  before_action :set_country_currency, only: %i[show edit update destroy]
  before_action :load_collections, only: %i[new edit create update index]

  def index
    @q_country  = params[:country_id].presence
    @q_currency = params[:currency_id].presence
    scope = System::CountryCurrency.includes(:country, :currency).order(:country_id, :currency_id)
    scope = scope.where(country_id:  @q_country)  if @q_country
    scope = scope.where(currency_id: @q_currency) if @q_currency
    @country_currencies = scope
  end

  def show; end

  def new
    @country_currency = System::CountryCurrency.new(default_for_country: true)
  end

  def create
    @country_currency = System::CountryCurrency.new(country_currency_params)
    if @country_currency.save
      redirect_to system_country_currency_path(@country_currency), notice: "Mapping created"
    else
      load_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @country_currency.update(country_currency_params)
      redirect_to [ :system, @country_currency ], notice: "Mapping updated"
    else
      load_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @country_currency.destroy
    redirect_to system_country_currencies_path, notice: "Mapping removed"
  end

  private

  def set_country_currency
    @country_currency = System::CountryCurrency.find(params[:id])
  end

  def load_collections
    @countries  = System::Country.order(:name).select(:id, :name)
    @currencies = System::Currency.order(:code).select(:id, :code, :name)
  end

  def country_currency_params
    params.require(:system_country_currency).permit(
      :country_id, :currency_id, :default_for_country, :valid_from, :valid_to
    )
  end
end
