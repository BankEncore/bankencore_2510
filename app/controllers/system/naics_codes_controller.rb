# app/controllers/system/naics_codes_controller.rb
class System::NaicsCodesController < ApplicationController
  include Pagy::Backend
  before_action :set_naics, only: %i[show edit update destroy]

    def index
    @q = params[:q].to_s.strip
    @level = params[:level].presence
    scope = System::NaicsCode.order(:year, :code)
    scope = scope.where("code ILIKE ? OR title ILIKE ?", "%#{@q}%", "%#{@q}%") if @q.present?
    scope = scope.where(level: @level.to_i) if @level
    @pagy, @naics_codes = pagy(scope, items: (params[:items].presence || 50).to_i)
    end

  def show
    @parent         = @naics.parent
    @ancestors      = @naics.ancestors.order(Arel.sql("char_length(code)"))
    @lineage        = @ancestors.to_a + [ @naics ]
    @expanded_codes = (@ancestors.pluck(:code) + [ @naics.code ])
  end

  def new
    @naics = System::NaicsCode.new(year: "2022")
  end

  def edit; end

  def create
    @naics = System::NaicsCode.new(naics_params)
    if @naics.save
      redirect_to system_naics_code_path(@naics), notice: "NAICS code created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @naics.update(naics_params)
      redirect_to system_naics_code_path(@naics), notice: "NAICS code updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @naics.destroy
    redirect_to system_naics_codes_path, notice: "NAICS code deleted."
  end

  private

  def set_naics
    @naics = System::NaicsCode.find(params[:id])
  end

  def naics_params
    params.require(:system_naics_code).permit(
      :year, :code, :title, :sector, :parent_code, :level, :description, :active
    )
  end
end
