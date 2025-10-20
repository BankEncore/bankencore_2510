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
