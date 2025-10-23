# app/controllers/branches_controller.rb
# new
class BranchesController < ApplicationController
  def index
    @branches = policy_scope(Branch).active
  end
  def show
    @branch = Branch.find_by!(public_id: params[:public_id])
    authorize @branch
  end
end
