# app/controllers/system/reference_lists_controller.rb
class System::ReferenceListsController < ApplicationController
  before_action :set_list, only: %i[show edit update destroy]

  def index
    @lists = System::ReferenceList.order(:name)
  end

  def show; end
  def new  ; @list = System::ReferenceList.new end
  def edit ; end

  def create
    @list = System::ReferenceList.new(list_params)
    @list.save ? redirect_to([ :system, @list ], notice: "Saved") : render(:new, status: :unprocessable_entity)
  end

  def update
    @list.update(list_params) ? redirect_to([ :system, @list ], notice: "Updated") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @list.destroy
    redirect_to system_reference_lists_path, notice: "Deleted"
  end

  private
  def set_list
    @list = System::ReferenceList.find_by!(public_id: params[:public_id])  # <- use :public_id
  end
  def list_params = params.require(:reference_list).permit(:name, :description, :active)
end
