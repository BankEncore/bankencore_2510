# app/controllers/admin/system/naics_codes_controller.rb
# new
class Admin::System::NaicsCodesController < Admin::BaseController
  include Pagy::Backend
  before_action :load_version
  before_action :set_naics, only: %i[show edit update destroy]

  # GET /admin/system/naics/:version
  def index
    authorize [ :admin, :system, ::System::NaicsCode ]

    @versions = ::System::NaicsCode.distinct.order(version: :desc).pluck(:version)
    if params[:version].blank?
      latest = @versions.first
      redirect_to admin_system_naics_codes_path(version: latest) and return
    end

    scope = policy_scope(::System::NaicsCode).where(version: @version).order(:code)
    if params[:q].present?
      q = "%#{params[:q].to_s.strip}%"
      scope = scope.where("code ILIKE ? OR title ILIKE ?", q, q)
    end

    @pagy, @naics_codes = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /admin/system/naics/:version/:code
  def show
    authorize [ :admin, :system, @naics ]
    @ancestors = []
    node = @naics
    while node&.parent_code.present?
      parent = ::System::NaicsCode.find_by(version: node.version, code: node.parent_code)
      break unless parent
      @ancestors.unshift(parent)
      node = parent
    end
  end

  # GET /admin/system/naics/:version/new
  def new
    @naics = ::System::NaicsCode.new(version: @version)
    authorize [ :admin, :system, @naics ]
  end

  # POST /admin/system/naics/:version
  def create
    @naics = ::System::NaicsCode.new(naics_params.merge(version: @version))
    authorize [ :admin, :system, @naics ]
    if @naics.save
      redirect_to admin_system_naics_code_admin_path(version: @naics.version, code: @naics.code), notice: "Created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/system/naics/:version/:code/edit
  def edit
    authorize [ :admin, :system, @naics ]
  end

  # PATCH/PUT /admin/system/naics/:version/:code
  def update
    authorize [ :admin, :system, @naics ]
    if @naics.update(naics_params)
      redirect_to admin_system_naics_code_admin_path(version: @naics.version, code: @naics.code), notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/system/naics/:version/:code
  def destroy
    authorize [ :admin, :system, @naics ]
    @naics.destroy!
    redirect_to admin_system_naics_codes_path(version: @version), notice: "Deleted"
  end

  private

  def load_version
    @version = params[:version].to_s.presence
  end

  def set_naics
    code = params[:code].to_s.strip
    @naics = ::System::NaicsCode.find_by!(version: @version, code: code)
    # canonicalize if the URL doesn’t match normalized values
    if params[:code] != @naics.code
      redirect_to admin_system_naics_code_admin_path(version: @naics.version, code: @naics.code), status: :moved_permanently
    end
  end

  # Strong params for the new schema
  def naics_params
    params.require(:system_naics_code).permit(:code, :title, :description, :parent_code, :level, :sector, :active)
  end
end
