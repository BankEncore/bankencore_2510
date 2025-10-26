# app/controllers/admin/system/reference_lists_controller.rb
class Admin::System::ReferenceListsController < Admin::BaseController
  before_action :set_list, only: %i[show edit update destroy]

  # GET /admin/system/reference_lists
  def index
    authorize [:admin, System::ReferenceList]
    @lists = policy_scope([:admin, System::ReferenceList])
  end

  # GET /admin/system/reference_lists/:id
  def show
    authorize [:admin, @list]
  end

  # GET /admin/system/reference_lists/new
  def new
    @list = System::ReferenceList.new
    authorize [:admin, @list]
  end

  # POST /admin/system/reference_lists
  def create
    @list = System::ReferenceList.new(list_params)
    authorize [:admin, @list]
    if @list.save
      redirect_to [:admin, :system, @list], notice: "Created"
    else
      render :new, status: :unprocessable_content
    end
  end

  # GET /admin/system/reference_lists/:id/edit
  def edit
    authorize [:admin, @list]
  end

  # PATCH/PUT /admin/system/reference_lists/:id
  def update
    authorize [:admin, @list]
    if @list.update(list_params)
      redirect_to [:admin, :system, @list], notice: "Updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /admin/system/reference_lists/:id
  def destroy
    authorize [:admin, @list]
    @list.destroy!
    redirect_to [:admin, :system, :reference_lists], notice: "Deleted"
  end

  private

  def set_list
    pid = params[:public_id] || params[:reference_list_public_id] || params[:id]
    @list = System::ReferenceList.find_by!(public_id: pid)
  end

  def list_params
    p = params.require(:system_reference_list)
              .permit(:key, :name, :description, :schema_version, :visibility, :tags)
    p[:tags] = p[:tags].to_s.split(",").map(&:strip).reject(&:blank?)
    p
  end
end
