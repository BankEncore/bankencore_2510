# app/controllers/admin/system/reference_values_controller.rb
# new
class Admin::System::ReferenceValuesController < ApplicationController
    @lists = policy_scope(System::ReferenceValue)
    authorize System::ReferenceValue

  def index
    @values = policy_scope(System::ReferenceValue)
                .where(reference_list_id: @list.id).ordered
    authorize System::ReferenceValue
  end

  def show
    authorize @value
  end

  def new
    @value = @list.reference_values.new(active: true, position: 0, metadata: {})
    authorize @value
  end

  def create
    @value = @list.reference_values.new(value_params)
    authorize @value
    if @value.save
      redirect_to admin_system_reference_value_path(@value.public_id)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @value
  end

  def update
    authorize @value
    if @value.update(value_params)
      redirect_to admin_system_reference_value_path(@value.public_id)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @value
    @value.destroy
    redirect_to admin_system_reference_list_reference_values_path(@value.reference_list.public_id)
  end

  private

  # For nested routes: /admin/system/reference_lists/:reference_list_public_id/reference_values
  def set_parent
    pid = params[:reference_list_public_id] || params[:public_id]
    @list = System::ReferenceList.find_by!(public_id: pid)
  end

  # For shallow routes: /admin/system/reference_values/:public_id
  def set_value
    @value = System::ReferenceValue.find_by!(public_id: params[:public_id])
    @list  = @value.reference_list
  end

  def value_params
    p = params.require(:system_reference_value).permit(
      :reference_list_id, :parent_id, :key, :code, :label, :short_label,
      :description, :position, :active, :effective_from, :effective_to,
      :metadata_json
    )
    if p.key?(:metadata_json)
      p[:metadata] = p.delete(:metadata_json).presence ? JSON.parse(p[:metadata_json]) : {}
    end
    p
  rescue JSON::ParserError => e
    (@value || System::ReferenceValue.new).errors.add(:metadata, "invalid JSON: #{e.message}")
    p.except(:metadata) # prevent crash; validation will surface error
  end
end
