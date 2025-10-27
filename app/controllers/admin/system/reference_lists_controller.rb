# app/controllers/admin/system/reference_lists_controller.rb
class Admin::System::ReferenceListsController < Admin::BaseController
  before_action :set_list, only: %i[show edit update destroy]

  def index
    authorize [ :admin, System::ReferenceList ]
    @lists = policy_scope([ :admin, System::ReferenceList ])
  end

  def show
    authorize [ :admin, @list ]
  end

  def new
    @list = System::ReferenceList.new(active: true)
    authorize [ :admin, @list ]
  end

  def create
    @list = System::ReferenceList.new(list_params)
    authorize [ :admin, @list ]
    if @list.save
      redirect_to [ :admin, :system, @list ], notice: "Created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [ :admin, @list ]
  end

  def update
    authorize [ :admin, @list ]
    if @list.update(list_params)
      redirect_to admin_system_reference_list_path(@list), notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [ :admin, @list ]
    @list.destroy!
    redirect_to admin_system_reference_lists_path, notice: "Deleted"
  end

  private

  def set_list
    @list = System::ReferenceList.find_by!(key: params[:key])
  end

  # do not permit :key unless you support renaming
  def list_params
    params.require(:system_reference_list).permit(:name, :description)
  end
end
