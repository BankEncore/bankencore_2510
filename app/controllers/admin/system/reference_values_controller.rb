# app/controllers/admin/system/reference_values_controller.rb
class Admin::System::ReferenceValuesController < Admin::BaseController
  before_action :set_list
  before_action :set_value, only: %i[show edit update destroy]

  def index
    authorize [ :admin, @list ]
    @values = @list.reference_values.order(:sort_index, :code)
  end

  def new
    @value = System::ReferenceValue.new(reference_list: @list, sort_index: 50, active: true)
    authorize [ :admin, @value ]
  end

  def create
    @value = @list.reference_values.new(value_params)
    authorize [ :admin, @value ]
    if @value.save
      redirect_to admin_system_reference_list_reference_value_path(@list, @value), notice: "Created"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize [ :admin, @value ]
  end

  def update
    authorize [ :admin, @value ]
    if @value.update(value_params)
      redirect_to admin_system_reference_list_reference_value_path(@list, @value), notice: "Updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize [ :admin, @value ]
    @value.destroy!
    redirect_to admin_system_reference_list_reference_value_path(@list, @value), notice: "Deleted"
  end

  private

  def set_list
    @list = System::ReferenceList.find_by!(key: params[:reference_list_key] || params[:reference_list_id] || params[:key])
  end

  def set_value
    lookup = params[:code] || params[:id]
    @value = @list.reference_values.find_by!(code: lookup)
  end

  def value_params
    params.require(:system_reference_value).permit(
      :code, :name, :short_name, :description,
      :sort_index, :active, :external_code, :valid_from, :valid_to,
      metadata: {}
    )
  end
end
