# app/controllers/parties/organizations_controller.rb
class Parties::OrganizationsController < Parties::BaseController
  def show
    @organization = @party.organization
    authorize @organization || Parties::Organization
    head :not_found unless @organization
  end

  def create
    @organization = @party.build_organization(org_params)
    authorize @organization
    if @organization.save
      redirect_to party_path(@party), notice: "Organization created"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @organization = @party.organization
    authorize @organization
    if @organization.update(org_params)
      redirect_to party_path(@party), notice: "Organization updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @organization = @party.organization
    authorize @organization
    @organization&.destroy
    redirect_to party_path(@party), notice: "Organization deleted"
  end

  private
  def org_params
    params.require(:organization).permit(
      :established_on, :residence_country, :organization_type_code,
      :system_naics_code_id, :tax_exempt_code
    )
  end
end
