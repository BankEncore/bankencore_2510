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
    @naics = System::NaicsCode.find_by!(public_id: params[:public_id] || params[:id])
    @ancestors = []
    node = @naics
    while node&.parent_code.present?
      parent = System::NaicsCode.find_by(code: node.parent_code, year: node.year)
      break unless parent
      @ancestors.unshift(parent)
      node = parent
    end
    @lineage = @ancestors.dup
    @parent  = @ancestors.last
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

  def legacy_redirect
    record = System::NaicsCode.find(params[:id])
    redirect_to system_naics_code_path(record.public_id), status: :moved_permanently
  end

  private

def set_naics
  key = params[:public_id] || params[:id]
  @naics = ::System::NaicsCode.find_by!(public_id: key)
end

  def naics_params
    params.require(:system_naics_code).permit(
      params.require(:system_naics_code).permit(:year, :code, :title, :sector, :parent_code, :level, :description, :active)
    )
  end
end
