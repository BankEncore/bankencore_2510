# app/controllers/admin/system/regions_controller.rb
# new
class Admin::System::RegionsController < Admin::BaseController
  include Pagy::Backend
  before_action :set_region,        only: %i[show edit update destroy]
  before_action :load_collections,  only: %i[new edit create update]

  # GET /admin/system/regions
  # Filters: ?country_alpha2=US&kind=state&active=true&q=par
  def index
    authorize [:admin, :system, System::Region]

    scope = policy_scope(System::Region).order(:country_alpha2, :region_code)

    if (ca = params[:country_alpha2].to_s.upcase.presence)
      scope = scope.where(country_alpha2: ca)
    end
    if (k = params[:kind].to_s.strip.presence)
      scope = scope.where(kind: k)
    end
    unless params[:active].nil?
      scope = scope.where(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
    end
    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where("region_code ILIKE ? OR name ILIKE ? OR iso_code ILIKE ?", like, like, like)
    end

    @pagy, @regions = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /admin/system/regions/:iso_code
  def show
    authorize [:admin, :system, @region]
  end

  # GET /admin/system/regions/new
  def new
    @region = System::Region.new(active: true)
    authorize [:admin, :system, @region]
  end

  # POST /admin/system/regions
  def create
    @region = System::Region.new(region_params)
    normalize!(@region)
    @region.iso_code = "#{@region.country_alpha2}-#{@region.region_code}" if @region.country_alpha2 && @region.region_code
    authorize [:admin, :system, @region]

    if @region.save
      redirect_to admin_system_region_path(@region.iso_code), notice: "Created"
    else
      load_collections
      render :new, status: :unprocessable_content
    end
  end

  # GET /admin/system/regions/:iso_code/edit
  def edit
    authorize [:admin, :system, @region]
  end

  # PATCH/PUT /admin/system/regions/:iso_code
  def update
    authorize [:admin, :system, @region]
    attrs = region_params
    normalize_hash!(attrs)
    attrs[:iso_code] = "#{attrs[:country_alpha2] || @region.country_alpha2}-#{attrs[:region_code] || @region.region_code}"

    old_iso = @region.iso_code
    if @region.update(attrs)
      dest = @region.iso_code != old_iso ? admin_system_region_path(@region.iso_code) : admin_system_region_path(old_iso)
      redirect_to dest, notice: "Updated"
    else
      load_collections
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /admin/system/regions/:iso_code
  def destroy
    authorize [:admin, :system, @region]
    @region.destroy!
    redirect_to admin_system_regions_path, notice: "Deleted"
  end

  private

  def set_region
    iso = params[:iso_code].to_s.upcase
    @region = System::Region.find_by!(iso_code: iso)
    redirect_to admin_system_region_path(@region.iso_code), status: :moved_permanently if params[:iso_code] != @region.iso_code
  end

  def region_params
    params.require(:system_region).permit(:country_alpha2, :region_code, :name, :kind, :active, metadata: {})
  end

  def normalize!(row)
    row.country_alpha2 = row.country_alpha2&.upcase
    row.region_code    = row.region_code&.upcase
  end

  def normalize_hash!(h)
    h[:country_alpha2] = h[:country_alpha2].to_s.upcase if h.key?(:country_alpha2)
    h[:region_code]    = h[:region_code].to_s.upcase    if h.key?(:region_code)
  end

  def load_collections
    @countries = System::Country.order(:alpha2).pluck(:alpha2, :iso_short_name)
    @kinds     = %w[state province department district territory region prefecture canton county].freeze
  end
end
