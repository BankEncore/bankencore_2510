# app/controllers/admin/system/currencies_controller.rb
# new
class Admin::System::CurrenciesController < Admin::BaseController
  include Pagy::Backend
  before_action :set_currency, only: %i[show edit update destroy]

  # GET /admin/system/currencies
  def index
    authorize [:admin, :system, System::Currency]
    scope = policy_scope(System::Currency).order(:code)
    if (q = params[:q].to_s.strip.presence)
      ilike = "%#{q}%"
      scope = scope.where("code ILIKE ? OR name ILIKE ? OR full_name ILIKE ?", ilike, ilike, ilike)
    end
    @pagy, @currencies = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  # GET /admin/system/currencies/:code
  def show
    authorize [:admin, :system, @currency]
  end

  # GET /admin/system/currencies/new
  def new
    @currency = System::Currency.new(active: true, minor_units: 2)
    authorize [:admin, :system, @currency]
  end

  # POST /admin/system/currencies
  def create
    @currency = System::Currency.new(currency_params)
    normalize!(@currency)
    authorize [:admin, :system, @currency]
    if @currency.save
      redirect_to admin_system_currency_path(@currency.code), notice: "Created"
    else
      render :new, status: :unprocessable_content
    end
  end

  # GET /admin/system/currencies/:code/edit
  def edit
    authorize [:admin, :system, @currency]
  end

  # PATCH/PUT /admin/system/currencies/:code
  def update
    authorize [:admin, :system, @currency]
    attrs = currency_params
    normalize_hash!(attrs)

    # Allow renaming code/numeric; redirect to canonical path if code changed.
    old_code = @currency.code
    if @currency.update(attrs)
      new_code = @currency.code
      if new_code != old_code
        redirect_to admin_system_currency_path(new_code), notice: "Updated"
      else
        redirect_to admin_system_currency_path(@currency.code), notice: "Updated"
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /admin/system/currencies/:code
  def destroy
    authorize [:admin, :system, @currency]
    @currency.destroy!
    redirect_to admin_system_currencies_path, notice: "Deleted"
  end

  private

  def set_currency
    code = params[:code].to_s.upcase
    @currency = System::Currency.find_by!(code: code)
    # canonicalize if path casing differs
    redirect_to admin_system_currency_path(@currency.code), status: :moved_permanently if params[:code] != @currency.code
  end

  def currency_params
    params.require(:system_currency).permit(
      :code, :numeric, :name, :full_name, :minor_units, :symbol, :unicode_codepoint, :active
    )
  end

  def normalize!(row)
    row.code = row.code&.upcase
    row.numeric = row.numeric&.rjust(3, "0")
  end

  def normalize_hash!(h)
    h[:code]    = h[:code].to_s.upcase if h.key?(:code)
    h[:numeric] = h[:numeric].to_s.rjust(3, "0") if h.key?(:numeric)
  end
end
