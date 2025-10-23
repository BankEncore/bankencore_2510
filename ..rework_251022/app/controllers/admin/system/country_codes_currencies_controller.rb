# app/controllers/admin/system/country_currencies_controller.rb
# new
class Admin::System::CountryCurrenciesController < Admin::BaseController
  include Pagy::Backend

  before_action :set_row,           only: %i[show edit update destroy]
  before_action :load_collections,  only: %i[index new edit create update]

  # GET /admin/system/country_currencies
  # Filters: ?country_alpha2=US&currency_code=USD&q=usd
  def index
    authorize [:admin, :system, ::System::CountryCurrency]

    scope = policy_scope(::System::CountryCurrency)
              .includes(:country, :currency)
              .order(:country_alpha2, :currency_code)

    if (ca = params[:country_alpha2].to_s.upcase.presence)
      scope = scope.where(country_alpha2: ca)
    end
    if (cc = params[:currency_code].to_s.upcase.presence)
      scope = scope.where(currency_code: cc)
    end
    if (q = params[:q].to_s.strip.presence)
      ilike = "%#{q}%"
      scope = scope.where(<<~SQL.squish, ilike: ilike, ilike2: ilike)
        currency_code ILIKE :ilike OR country_alpha2 ILIKE :ilike2
      SQL
    end

    @pagy, @country_currencies = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /admin/system/country_currencies/US-USD
  def show
    authorize [:admin, :system, @country_currency]
  end

  def new
    @country_currency = ::System::CountryCurrency.new
    authorize [:admin, :system, @country_currency]
  end

  def edit
    authorize [:admin, :system, @country_currency]
  end

  # POST /admin/system/country_currencies
  def create
    @country_currency = ::System::CountryCurrency.new(permitted_params)
    normalize_keys(@country_currency)
    authorize [:admin, :system, @country_currency]

    if @country_currency.save
      redirect_to admin_system_country_currency_path(
        country_alpha2: @country_currency.country_alpha2,
        currency_code:  @country_currency.currency_code
      ), notice: "Created"
    else
      load_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/system/country_currencies/US-USD
  def update
    authorize [:admin, :system, @country_currency]
    attrs = permitted_params
    normalize_hash!(attrs)

    if @country_currency.update(attrs)
      redirect_to admin_system_country_currency_path(
        country_alpha2: @country_currency.country_alpha2,
        currency_code:  @country_currency.currency_code
      ), notice: "Updated"
    else
      load_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [:admin, :system, @country_currency]
    @country_currency.destroy!
    redirect_to admin_system_country_currencies_path, notice: "Deleted"
  end

  private

  # Path format: /admin/system/country_currencies/:country_alpha2-:currency_code
  def set_row
    if params[:country_alpha2].present? && params[:currency_code].present?
      ca = params[:country_alpha2].to_s.upcase
      cc = params[:currency_code].to_s.upcase
    else
      # fallback if a single param like "US-USD" is routed as :id
      ca, cc = params[:id].to_s.split("-", 2).map { |s| s.to_s.upcase }
    end

    @country_currency = ::System::CountryCurrency.find_by!(country_alpha2: ca, currency_code: cc)

    # Canonicalize if path casing differs
    if params[:country_alpha2]&.upcase != ca || params[:currency_code]&.upcase != cc
      redirect_to admin_system_country_currency_path(country_alpha2: ca, currency_code: cc), status: :moved_permanently
    end
  end

  def permitted_params
    params.require(:system_country_currency)
          .permit(:country_alpha2, :currency_code, :is_primary, :legal_tender, :valid_from, :valid_to)
  end

  def normalize_hash!(h)
    h[:country_alpha2] = h[:country_alpha2].to_s.upcase if h.key?(:country_alpha2)
    h[:currency_code]  = h[:currency_code].to_s.upcase  if h.key?(:currency_code)
  end

  def normalize_keys(row)
    row.country_alpha2 = row.country_alpha2&.upcase
    row.currency_code  = row.currency_code&.upcase
  end

  def load_collections
    @countries  = ::System::Country.order(:iso_short_name).select(:alpha2, :iso_short_name)
    @currencies = ::System::Currency.order(:code).select(:code, :name)
  end
end
