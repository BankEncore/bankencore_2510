# app/controllers/parties/postal_addresses_controller.rb
class Parties::PostalAddressesController < Parties::BaseController
  before_action :set_addr, only: %i[edit update destroy]

  def index
    authorize Parties::PostalAddress
    @postal_addresses = @party.postal_addresses.order(preferred: :desc, id: :desc)
  end

  def new
    @postal_address = @party.postal_addresses.build
    authorize @postal_address
  end

  def create
    @postal_address = @party.postal_addresses.build(postal_address_params)
    authorize @postal_address

    if @postal_address.save
      redirect_to party_path(@party), notice: "Address added"
    else
      if @postal_address.errors[:preferred].present?
        flash[:alert] = "Only one preferred record is allowed per party."
        redirect_to party_path(@party)
      else
        flash.now[:alert] = preferred_alert_for(@postal_address)
        @party.postal_addresses.reload
        render "parties/parties/show", status: :unprocessable_content
      end
    end
  end

  def update
    authorize @addr
    if @addr.update(addr_params)
      redirect_to party_path(@party), notice: "Address updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @addr
    @addr.destroy
    redirect_to party_path(@party), notice: "Address deleted"
  end

  private
  def set_addr = @addr = @party.postal_addresses.find(params[:id])
  def postal_address_params
    params.require(:parties_postal_address)
          .permit(:line1, :line2, :city, :region, :postal_code, :country, :preferred, :valid_from, :valid_to)
  end
end
