# app/controllers/parties/identities_controller.rb
class Parties::IdentitiesController < Parties::BaseController
  before_action :set_identity, only: %i[edit update destroy]

  def index
    authorize Parties::Identity
    @identities = @party.identities.order(id: :desc)
  end

  def new
    @identity = @party.identities.build
    authorize @identity
  end

  def create
    @identity = @party.identities.build(identity_params)
    authorize @identity
    if @identity.save
      redirect_to party_path(@party), notice: "Identity added"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @identity
    if @identity.update(identity_params)
      redirect_to party_path(@party), notice: "Identity updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @identity
    @identity.destroy
    redirect_to party_path(@party), notice: "Identity deleted"
  end

  private
  def set_identity = @identity = @party.identities.find(params[:id])
  def identity_params
    params.require(:parties_identity).permit(
      :identity_type_code, :number, :issuing_country, :system_region_id,
      :issuer_name, :issued_on, :expires_on, :metadata
    )
  end
end
