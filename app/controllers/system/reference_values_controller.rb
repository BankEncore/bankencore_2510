class System::ReferenceValuesController < ApplicationController
  before_action :set_parent, only: %i[index new create]
  before_action :set_value,  only: %i[show edit update destroy]
  after_action  :verify_authorized

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
      render :new, status: :unprocessable_entity
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
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @value
    @value.destroy
    redirect_to admin_system_reference_list_reference_values_path(@value.reference_list.public_id)
  end

  private
  def set_parent = @list = System::ReferenceList.find_by!(public_id: params[:reference_list_public_id])
  def set_value  = @value = System::ReferenceValue.find_by!(public_id: params[:public_id])
  def value_params
    params.require(:system_reference_value).permit(
      :parent_id, :key, :code, :label, :short_label, :description,
      :position, :active, :effective_from, :effective_to, :reference_list_id,
      metadata: {}
    )
  end
end
