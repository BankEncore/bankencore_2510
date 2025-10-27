# app/controllers/parties/phones_controller.rb
class Parties::PhonesController < ApplicationController
  include Parties::BelongsToParty
  before_action :set_phone, only: %i[show update destroy]

  def index
    authorize @party, :show?
    render json: @party.phones.order(preferred: :desc, created_at: :asc)
  end

  def show
    authorize @phone
    render json: @phone
  end

  def create
    rec = @party.phones.build(phone_params)
    authorize rec
    rec.save ? render(json: rec, status: :created) :
               render(json: { errors: rec.errors.full_messages }, status: :unprocessable_entity)
  end

  def update
    authorize @phone
    @phone.update(phone_params) ? render(json: @phone) :
      render(json: { errors: @phone.errors.full_messages }, status: :unprocessable_entity)
  end

  def destroy
    authorize @phone
    @phone.destroy
    head :no_content
  end

  private
  def set_phone = @phone = @party.phones.find(params[:id])
  def phone_params
    params.require(:parties_phone).permit(:phone_type_code, :e164, :verified_at, :preferred, :valid_from, :valid_to, :invalid_reason)
  end
end
