# app/controllers/system/reference_values_controller.rb
class System::ReferenceValuesController < ApplicationController
  before_action :set_list

  def index
    @values = @list.reference_values.order(:sort_index, :code)
  end

  def show
    @value = @list.reference_values.find_by!(code: params[:code] || params[:id])
  end

  private

  def set_list
    @list = System::ReferenceList.find_by!(key: params[:reference_list_key] || params[:reference_list_id] || params[:key])
  end
end
