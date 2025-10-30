# app/controllers/parties/phones_controller.rb
class Parties::PhonesController < Parties::BaseController
  before_action :set_phone, only: %i[edit update destroy]

  def index
    authorize Parties::Phone
    @phones = @party.phones.order(preferred: :desc, id: :desc)
  end

  def new
    @phone = @party.phones.build
    authorize @phone
  end

  def create
    @phone = @party.phones.build(phone_params)
    authorize @phone

    if @phone.save
      redirect_to party_path(@party), notice: "Phone added"
    else
      if @phone.errors[:preferred].present?   # single-preferred violation path
        flash[:alert] = "Only one preferred record is allowed per party."
        redirect_to party_path(@party)
      else
        flash.now[:alert] = preferred_alert_for(@phone)
        @party.phones.reload
        render "parties/parties/show", status: :unprocessable_content
      end
    end
  end

  def update
    authorize @phone
    if @phone.update(phone_params)
      redirect_to party_path(@party), notice: "Phone updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @phone
    @phone.destroy
    redirect_to party_path(@party), notice: "Phone deleted"
  end

  private
  def set_phone = @phone = @party.phones.find(params[:id])
  def phone_params
    params.require(:parties_phone).permit(:phone_type_code, :e164, :extension, :preferred)
  end
end
