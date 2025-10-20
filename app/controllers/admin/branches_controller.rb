# app/controllers/admin/branches_controller.rb
class Admin::BranchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_branch, only: %i[show edit update destroy]

  def index
    @branches = policy_scope(Branch, policy_scope_class: Admin::BranchPolicy::Scope).order(:code)
    authorize Branch, policy_class: Admin::BranchPolicy
  end

  def show
    authorize @branch, policy_class: Admin::BranchPolicy
  end

  def new
    @branch = Branch.new
    authorize @branch, policy_class: Admin::BranchPolicy
  end

  def create
    @branch = Branch.new(branch_params)
    authorize @branch, policy_class: Admin::BranchPolicy
    if @branch.save
      redirect_to [ :admin, @branch ], notice: "Branch created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @branch, policy_class: Admin::BranchPolicy
  end

  def update
    authorize @branch, policy_class: Admin::BranchPolicy
    if @branch.update(branch_params)
      redirect_to [ :admin, @branch ], notice: "Branch updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @branch, policy_class: Admin::BranchPolicy
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
