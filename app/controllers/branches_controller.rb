# app/controllers/branches_controller.rb
class BranchesController < ApplicationController
  def index
    @branches = policy_scope(Branch).order(:code)
    authorize Branch
  end

  def show
    @branch = Branch.find_by!(public_id: params[:id]) rescue Branch.find(params[:id])
    authorize @branch
  end
end

# app/controllers/admin/branches_controller.rb
class Admin::BranchesController < ApplicationController
  before_action :set_branch, only: %i[show edit update destroy]

  def index
    @branches = policy_scope(Branch).order(:code)
    authorize [:admin, Branch]
  end

  def show
    authorize [:admin, @branch]
  end

  def new
    @branch = Branch.new
    authorize [:admin, @branch]
  end

  def create
    @branch = Branch.new(branch_params)
    authorize [:admin, @branch]
    if @branch.save
      redirect_to [:admin, @branch], notice: "Branch created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [:admin, @branch]
  end

  def update
    authorize [:admin, @branch]
    if @branch.update(branch_params)
      redirect_to [:admin, @branch], notice: "Branch updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [:admin, @branch]
    @branch.destroy
    redirect_to admin_branches_path, notice: "Branch deleted."
  end

  private

  def set_branch
    @branch = Branch.find_by!(public_id: params[:id]) rescue Branch.find(params[:id])
  end

  def branch_params
    params.require(:branch).permit(:code, :name, :status)
  end
end
