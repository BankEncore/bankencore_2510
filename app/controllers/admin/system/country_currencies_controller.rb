# app/controllers/admin/system/reference_lists_controller.rb
class Admin::System::CountryCurrenciesController < Admin::BaseController
  include Pagy::Backend

  def index
    authorize ::System::CountryCurrency

    @countries  = ::System::Country.order(:name).select(:id, :name)
    @currencies = ::System::Currency.order(:code).select(:id, :code, :name)

    scope = policy_scope(::System::CountryCurrency).includes(:country, :currency)
    scope = scope.where(country_id: params[:country_id])   if params[:country_id].present?
    scope = scope.where(currency_id: params[:currency_id]) if params[:currency_id].present?

    @pagy, @country_currencies = pagy(scope.order(:country_id, :currency_id), items: (params[:items] || 50))
  end

  def show; authorize @list; end
  def new  ; @list = System::ReferenceList.new; authorize @list; end

  def create
    @list = System::ReferenceList.new(list_params); authorize @list
    if @list.save then redirect_to [ :admin, :system, @list ], notice: "Created"
    else render :new, status: :unprocessable_entity
    end
  end

  def edit; authorize @list; end

  def update
    authorize @list
    if @list.update(list_params) then redirect_to [ :admin, :system, @list ], notice: "Updated"
    else render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @list
    @list.destroy!
    redirect_to [ :admin, :system, :reference_lists ], notice: "Deleted"
  end

  private
  def set_list = @list = System::ReferenceList.find_by!(public_id: params[:id])
  def list_params = params.require(:system_reference_list).permit(:key, :name, :description, :active)
end
