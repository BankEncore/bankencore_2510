# app/controllers/parties/web_addresses_controller.rb
class Parties::WebAddressesController < Parties::BaseController
  before_action :set_web, only: %i[edit update destroy]

  def index
    authorize Parties::WebAddress
    @web_addresses = @party.web_addresses.order(preferred: :desc, id: :desc)
  end

  def new
    @web = @party.web_addresses.build
    authorize @web
  end

  def create
    @web_address = @party.web_addresses.build(web_address_params)
    authorize @web_address

    if @web_address.save
      redirect_to party_path(@party), notice: "Web address added"
    else
      if @web_address.errors[:preferred].present?
        flash[:alert] = "Only one preferred record is allowed per party."
        redirect_to party_path(@party)
      else
        flash.now[:alert] = preferred_alert_for(@web_address)
        @party.web_addresses.reload
        render "parties/parties/show", status: :unprocessable_content
      end
    end
  end

  def update
    authorize @web_address
    if @web_address.update(web_address_params)
      redirect_to party_path(@party), notice: "Web address updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @web_address
    @web_address.destroy
    redirect_to party_path(@party), notice: "Web address deleted"
  end

  private
  def set_web_address = @web_address = @party.web_addresses.find(params[:id])
  def web_address_params
    params.require(:parties_web_address).permit(:url, :preferred)
  end
end
