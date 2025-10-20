# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_collections, only: %i[new edit]

  def index
    @users = policy_scope(User, policy_scope_class: Admin::UserPolicy::Scope).order(:email)
    authorize User, policy_class: Admin::UserPolicy
  end

  def show
    authorize @user, policy_class: Admin::UserPolicy
  end

  def new
    @user = User.new
    authorize @user, policy_class: Admin::UserPolicy
  end

  def create
    @user = User.new(params.require(:user).permit(policy(@user).permitted_attributes))
    authorize @user, policy_class: Admin::UserPolicy
    if @user.save
      redirect_to [ :admin, @user ], notice: "User created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user, policy_class: Admin::UserPolicy
  end

  def update
    authorize @user, policy_class: Admin::UserPolicy
    permitted = policy(@user).permitted_attributes
    attrs = params.require(:user).permit(permitted)

    if attrs[:branch_ids]
      allowed = policy_scope(::Branch).where(id: attrs[:branch_ids]).pluck(:id)
      attrs[:branch_ids] = allowed
    end

    if @user.update(attrs)
      redirect_to [ :admin, @user ], notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user, policy_class: Admin::UserPolicy
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_collections
    @branches = Branch.order(:code).pluck(:code, :id)
  end
end
