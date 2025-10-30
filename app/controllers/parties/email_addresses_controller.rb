# app/controllers/parties/email_addresses_controller.rb
class Parties::EmailAddressesController < Parties::BaseController
  before_action :set_email, only: %i[edit update destroy]

  def index
    authorize Parties::EmailAddress
    @emails = @party.email_addresses.order(preferred: :desc, id: :desc)
  end

  def new
    @email = @party.email_addresses.build
    authorize @email
  end

  def create
    @email = @party.email_addresses.build(email_params)
    authorize @email
    if @email.save
      redirect_to party_path(@party), notice: "Email added"
    else
      if @email.errors[:preferred].present?
        redirect_to party_path(@party),
          alert: "Only one preferred record is allowed per party.",
          status: :see_other
      else
        render plain: @email.errors.full_messages.to_sentence,
          status: :unprocessable_content # Rack warns: :unprocessable_content soon
      end
    end
  end

  def update
    authorize @email
    if @email.update(email_params)
      redirect_to party_path(@party), notice: "Email updated"
    else
      if @email.errors[:preferred].present?
        redirect_to party_path(@party),
          alert: "Only one preferred record is allowed per party.",
          status: :see_other
      else
        render plain: @email.errors.full_messages.to_sentence,
          status: :unprocessable_content
      end
    end
  end

  def destroy
    authorize @email
    @email.destroy
    redirect_to party_path(@party), notice: "Email deleted"
  end

  private
  def set_email = @email = @party.email_addresses.find(params[:id])
  def email_params
    params.require(:parties_email_address)
          .permit(:email_type_code, :email, :verified_at, :preferred, :valid_from, :valid_to)
  end
end
