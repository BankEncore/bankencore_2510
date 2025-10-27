# app/controllers/parties/email_addresses_controller.rb
class Parties::EmailAddressesController < ApplicationController
  include Parties::BelongsToParty
  before_action :set_email, only: %i[show update destroy]

  def index
    authorize @party, :show?
    render json: @party.email_addresses.order(preferred: :desc, created_at: :asc)
  end

  def show
    authorize @email
    render json: @email
  end

  def create
    rec = @party.email_addresses.build(email_params)
    authorize rec
    rec.save ? render(json: rec, status: :created) :
               render(json: { errors: rec.errors.full_messages }, status: :unprocessable_entity)
  end

  def update
    authorize @email
    @email.update(email_params) ? render(json: @email) :
      render(json: { errors: @email.errors.full_messages }, status: :unprocessable_entity)
  end

  def destroy
    authorize @email
    @email.destroy
    head :no_content
  end

  private
  def set_email = @email = @party.email_addresses.find(params[:id])
  def email_params
    params.require(:parties_email_address).permit(:email_type_code, :email, :verified_at, :preferred, :valid_from, :valid_to)
  end
end
