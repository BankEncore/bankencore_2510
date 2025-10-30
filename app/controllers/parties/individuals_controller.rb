# app/controllers/parties/individuals_controller.rb
class Parties::IndividualsController < Parties::BaseController
  def show
    @individual = @party.individual
    authorize @individual || Parties::Individual
    head :not_found unless @individual
  end

  def create
    @individual = @party.build_individual(individual_params)
    authorize @individual
    if @individual.save
      redirect_to party_path(@party), notice: "Individual created"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @individual = @party.individual
    authorize @individual
    if @individual.update(individual_params)
      redirect_to party_path(@party), notice: "Individual updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @individual = @party.individual
    authorize @individual
    @individual&.destroy
    redirect_to party_path(@party), notice: "Individual deleted"
  end

  private
  def individual_params
    params.require(:individual).permit(
      :residence_country, :birth_date, :gender_code, :marital_status_code,
      :immigration_status_code, :education_level_code, :home_ownership_code,
      :race_code, :employment_type_code, :occupation_code
    )
  end
end
