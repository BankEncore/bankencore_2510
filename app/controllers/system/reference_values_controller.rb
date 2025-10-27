# app/controllers/admin/system/reference_values_controller.rb
class Admin::System::ReferenceValuesController < Admin::BaseController
  before_action :set_list
  before_action :set_value, only: %i[show edit update destroy]

  def create
    @value = @list.reference_values.new(value_params)
    authorize [ :admin, @value ]
    if @value.save
      redirect_to admin_system_reference_value_path(@value), notice: "Created"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_list
    @list = System::ReferenceList.find_by!(key: params[:reference_list_key] || params[:reference_list_id] || params[:key])
  end

  def set_value
    @value = System::ReferenceValue.find(params[:id]) if params[:id]
  end

  def value_params
    params.require(:system_reference_value).permit(
      :code, :key, :name, :short_name, :description,
      :sort_index, :active, :external_code, :valid_from, :valid_to,
      metadata: {}
    )
  end
end
