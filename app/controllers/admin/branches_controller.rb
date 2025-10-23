# app/controllers/admin/branches_controller.rb
class Admin::BranchesController < Admin::BaseController
  before_action :set_branch, only: %i[show edit update destroy]

  def index
    @branches = policy_scope(Branch)
    authorize Branch, :index?
  end

  def show; end

  def new
    @branch = Branch.new
    authorize @branch
  end

  def create
    @branch = Branch.new(branch_params)
    authorize @branch
    if @branch.save
      redirect_to [ :admin, @branch ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @branch.update(branch_params)
      redirect_to [ :admin, @branch ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @branch.destroy
    redirect_to admin_branches_path
  end

  private

  def set_branch
    @branch = Branch.find_by!(public_id: params[:public_id])
    authorize @branch
  end

  def branch_params
    permitted = params.require(:branch).permit(
      :code, :name, :status, :time_zone,
      :address_1, :address_2, :city, :region_code, :postal_code,
      :country_alpha2, :phone, :fax, :email, :latitude, :longitude,
      *Branch::DAYS.flat_map { |d| [ :"#{d}_open", :"#{d}_close" ] }
    )

    hours = {}
    Branch::DAYS.each do |d|
      o = permitted.delete(:"#{d}_open").to_s.strip
      c = permitted.delete(:"#{d}_close").to_s.strip
      if o.present? && c.present?
        hours[d] = { "open" => o, "close" => c }
      else
        hours[d] = nil
      end
    end

    permitted[:operating_hours] = hours
    permitted
  end
end
