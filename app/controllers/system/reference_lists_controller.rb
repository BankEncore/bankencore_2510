class System::ReferenceListsController < ApplicationController
  before_action :set_list, only: %i[show edit update destroy]
  after_action  :verify_authorized

  def index
    @lists = policy_scope(System::ReferenceList).order(:key)
    authorize System::ReferenceList
  end

  def show
    authorize @list
  end

  def new
    @list = System::ReferenceList.new(visibility: "public", tags: [])
    authorize @list
  end

  def create
    @list = System::ReferenceList.new(list_params)
    authorize @list
    if @list.save
      redirect_to admin_system_reference_list_path(@list.public_id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @list
  end

  def update
    authorize @list
    if @list.update(list_params)
      redirect_to admin_system_reference_list_path(@list.public_id)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @list
    @list.destroy
    redirect_to admin_system_reference_lists_path
  end

  private
  def set_list = @list = System::ReferenceList.find_by!(public_id: params[:public_id])
  def list_params
    params.require(:system_reference_list)
          .permit(:key, :name, :description, :schema_version, :visibility, tags: [])
  end
end
