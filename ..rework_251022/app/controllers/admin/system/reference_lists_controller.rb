# app/controllers/admin/system/reference_lists_controller.rb
# new
class Admin::System::ReferenceListsController < Admin::BaseController
  def index
    @lists = policy_scope(System::ReferenceList)
    authorize System::ReferenceList
  end

  def show; authorize @list; end
  def new  ; @list = System::ReferenceList.new; authorize @list; end

  def create
    @list = System::ReferenceList.new(list_params); authorize @list
    if @list.save then redirect_to [ :admin, :system, @list ], notice: "Created"
    else render :new, status: :unprocessable_content
    end
  end

  def edit; authorize @list; end

  def update
    authorize @list
    if @list.update(list_params) then redirect_to [ :admin, :system, @list ], notice: "Updated"
    else render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @list
    @list.destroy!
    redirect_to [ :admin, :system, :reference_lists ], notice: "Deleted"
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
