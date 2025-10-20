# app/controllers/admin/system/naics_codes_controller.rb
class Admin::System::NaicsCodesController < Admin::BaseController
  include Pagy::Backend
  before_action :set_naics, only: %i[show edit update destroy]

  def index
    authorize ::System::NaicsCode
    @years = ::System::NaicsCode.distinct.order(year: :desc).pluck(:year)

    scope = policy_scope(::System::NaicsCode).order(:year, :code)
    scope = scope.where(year: params[:year]) if params[:year].present?

    if params[:q].present?
      q = "%#{params[:q].to_s.strip}%"
      scope = scope.where("code ILIKE ? OR title ILIKE ?", q, q)
    end

    @pagy, @naics_codes = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  def show
    authorize @naics
  end

  def new
    @naics = ::System::NaicsCode.new
    authorize @naics
  end

  def create
    @naics = ::System::NaicsCode.new(naics_params)
    authorize @naics
    if @naics.save
      redirect_to [ :admin, :system, @naics ], notice: "Created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @naics
  end

  def update
    authorize @naics
    if @naics.update(naics_params)
      redirect_to [ :admin, :system, @naics ], notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @naics
    @naics.destroy!
    redirect_to [ :admin, :system, :naics_codes ], notice: "Deleted"
  end

  private

  def set_naics
    @naics = ::System::NaicsCode.find_by!(public_id: params[:id])
  end

  def naics_params
    params.require(:system_naics_code).permit(:year, :code, :title, :level, :parent_code)
  end
end
