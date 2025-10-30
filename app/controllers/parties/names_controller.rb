# app/controllers/parties/names_controller.rb
class Parties::NamesController < Parties::BaseController
  before_action :set_name, only: %i[edit update destroy]

  def index
    authorize Parties::Name
    @names = @party.names.order(preferred: :desc, id: :desc)
  end

  def new
    @name = @party.names.build
    authorize @name
  end

  def create
    @name = @party.names.build(name_params)
    authorize @name
    if @name.save
      redirect_to party_path(@party), notice: "Name added"
    else
      redirect_to party_path(@party),
        alert: preferred_alert_for(@name),
        status: :see_other
    end
  end

  def update
    authorize @name
    if @name.update(name_params)
      redirect_to party_path(@party), notice: "Name updated"
    else
      render :edit, status: :unprocessable_content
        redirect_to party_path(@party),
        alert: preferred_alert_for(@name),
        status: :see_other
    end
  end

  def destroy
    authorize @name
    @name.destroy
    redirect_to party_path(@party), notice: "Name deleted"
  end

  private
  def set_name = @name = @party.names.find(params[:id])
  def name_params
    params.require(:parties_name).permit(
      :name_type_code, :full_name, :family_name, :given_name, :middle_name,
      :prefix_code, :suffix_code, :preferred, :valid_from, :valid_to
    )
  end
end
