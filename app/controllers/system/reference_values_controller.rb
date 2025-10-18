# app/controllers/system/reference_values_controller.rb
class System::ReferenceValuesController < ApplicationController
  before_action :set_list
  before_action :set_value, only: %i[show edit update destroy]

  def index
    @values = @list.reference_values.order(:position, :key)
  end

  def show; end
  def new  ; @value = @list.reference_values.new end
  def edit ; end

  def create
    @value = @list.reference_values.new(value_params)
    @value.save ? redirect_to([ @list, @value ], notice: "Saved") : render(:new, status: :unprocessable_entity)
  end

  def update
    @value.update(value_params) ? redirect_to([ @list, @value ], notice: "Updated") : render(:edit, status: :unprocessable_entity)
  end


  def destroy
    @value.destroy
    redirect_to [ @list, :reference_values ], notice: "Deleted"
  end

  private
  def set_list
    @list = System::ReferenceList.find_by!(public_id: params[:reference_list_public_id])
  end
  def set_value
    @value = @list.reference_values.find_by!(public_id: params[:public_id])
  end
  def value_params = params.require(:reference_value).permit(:key, :label, :description, :position, :active, :metadata)
end
