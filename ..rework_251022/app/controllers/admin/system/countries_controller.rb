# app/controllers/admin/system/countries_controller.rb
# new
class Admin::System::CountriesController < Admin::BaseController
  include Pagy::Backend
  before_action :set_country,        only: %i[show edit update destroy]
  before_action :load_collections,   only: %i[new edit create update]

  # GET /admin/system/countries
  # Filters: ?q=fr&currency=EUR&active=true
  def index
    authorize [:admin, :system, System::Country]

    scope = policy_scope(System::Country).order(:alpha2)
    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where(
        "alpha2 ILIKE ? OR alpha3 ILIKE ? OR numeric ILIKE ? OR iso_short_name ILIKE ? OR iso_long_name ILIKE ?",
        like, like, like, like, like
      )
    end
    if (cc = params[:currency].to_s.upcase.presence)
      scope = scope.where(currency_primary_code: cc)
    end
    unless params[:active].nil?
      scope = scope.where(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
    end

    @pagy, @countries = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /admin/system/countries/:alpha2
  def show
    authorize [:admin, :system, @country]
  end

  # GET /admin/system/countries/new
  def new
    @country = System::Country.new(active: true, postal_code_required: true)
    authorize [:admin, :system, @country]
  end

  # POST /admin/system/countries
  def create
    @country = System::Country.new(country_params)
    normalize!(@country)
    authorize [:admin, :system, @country]

    if @country.save
      redirect_to admin_system_country_path(@country.alpha2), notice: "Created"
    else
      load_collections
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/system/countries/:alpha2/edit
  def edit
    authorize [:admin, :system, @country]
  end

  # PATCH/PUT /admin/system/countries/:alpha2
  def update
    authorize [:admin, :system, @country]
    attrs = country_params
    normalize_hash!(attrs)

    old_alpha2 = @country.alpha2
    if @country.update(attrs)
      dest = admin_system_country_path(@country.alpha2)
      dest = admin_system_country_path(@country.alpha2) if @country.alpha2 != old_alpha2
      redirect_to dest, notice: "Updated"
    else
      load_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/system/countries/:alpha2
  def destroy
    authorize [:admin, :system, @country]
    @country.destroy!
    redirect_to admin_system_countries_path, notice: "Deleted"
  end

  private

  def set_country
    code = params[:alpha2].to_s.upcase
    @country = System::Country.find_by!(alpha2: code)
    # canonicalize case
    if params[:alpha2] != @country.alpha2
      redirect_to admin_system_country_path(@country.alpha2), status: :moved_permanently
    end
  end

  def country_params
    params.require(:system_country).permit(
      :alpha2, :alpha3, :numeric,
      :iso_short_name, :iso_long_name,
      :dialing_prefix,
      :postal_code_required, :postal_code_regex, :address_format,
      :currency_primary_code,
      :active,
      metadata: {}
    )
  end

  def normalize!(row)
    row.alpha2 = row.alpha2&.upcase
    row.alpha3 = row.alpha3&.upcase
    row.numeric = row.numeric.to_s.rjust(3, "0") if row.numeric.present?
    row.currency_primary_code = row.currency_primary_code&.upcase
  end

  def normalize_hash!(h)
    h[:alpha2] = h[:alpha2].to_s.upcase if h.key?(:alpha2)
    h[:alpha3] = h[:alpha3].to_s.upcase if h.key?(:alpha3)
    h[:numeric] = h[:numeric].to_s.rjust(3, "0") if h.key?(:numeric)
    h[:currency_primary_code] = h[:currency_primary_code].to_s.upcase if h.key?(:currency_primary_code)
  end

  def load_collections
    @currencies = System::Currency.order(:code).pluck(:code, :name) # for select
  end
end
