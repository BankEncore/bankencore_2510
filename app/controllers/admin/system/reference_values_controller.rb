# app/controllers/admin/system/reference_values_controller.rb
class Admin::System::ReferenceValuesController < Admin::BaseController
  include Pagy::Backend

  before_action :set_list
  before_action :set_value, only: %i[show edit update destroy]

  def index
    authorize [ :admin, :system, System::ReferenceValue ]
    scope = policy_scope(System::ReferenceValue)
              .where(reference_list_id: @list.id)
              .order(:sort_index, :code)

    if (q = params[:q].to_s.strip.presence)
      like = "%#{q}%"
      scope = scope.where("code ILIKE ? OR name ILIKE ? OR short_name ILIKE ? OR description ILIKE ?",
                          like, like, like, like)
    end
    unless params[:active].nil?
      scope = scope.where(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
    end

    @pagy, @reference_values = pagy(scope, items: (params[:items].presence || 50).to_i)
  end

  def show
    authorize [ :admin, :system, @value ]
  end

  def new
    @value = System::ReferenceValue.new(reference_list: @list, sort_index: 50, active: true)
    authorize [ :admin, :system, @value ]
  end

  def create
    @value = System::ReferenceValue.new(permitted.merge(reference_list: @list))
    authorize [ :admin, :system, @value ]
    if @value.save
      redirect_to admin_system_reference_list_reference_value_path(@list.key, @value.code), notice: "Created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [ :admin, :system, @value ]
  end

  def update
    authorize [ :admin, :system, @value ]
    if @value.update(permitted)
      redirect_to admin_system_reference_list_reference_value_path(@list.key, @value.code), notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [ :admin, :system, @value ]
    @value.destroy!
    redirect_to admin_system_reference_list_reference_values_path(@list.key), notice: "Deleted"
  end

  private

  def set_list
    key = params[:reference_list_key] || params[:key]
    @list = System::ReferenceList.find_by!(key: key.to_s)
  end

  def set_value
    @value = @list.reference_values.find_by!(code: params[:code].to_s)
  end

  def permitted
    params.require(:system_reference_value)
          .permit(:code, :name, :short_name, :description, :sort_index, :active,
                  :external_code, :valid_from, :valid_to, metadata: {})
  end
end
