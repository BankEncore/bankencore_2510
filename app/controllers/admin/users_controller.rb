# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_collections, only: %i[new edit]

  def index
    @users = policy_scope(User, policy_scope_class: Admin::UserPolicy::Scope).order(:email)
    authorize [ :admin, User ], :index?
  end

  def show
    authorize [ :admin, @user ]
  end

  def new
    @user = User.new
    authorize [ :admin, @user ]
  end

  def create
    @user = User.new(scrub_ids(user_params_for(@user)))
    authorize [ :admin, @user ]
    if @user.save
      redirect_to [ :admin, @user ], notice: "User created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [ :admin, @user ]
  end

  def update
    authorize [ :admin, @user ]
    attrs = scrub_ids(user_params_for(@user))
    if @user.update(attrs)
      redirect_to [ :admin, @user ], notice: "Updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [ :admin, @user ]
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find_by!(public_id: params[:public_id])
  end

  # Uses Pundit permitted attributes for the record
  def user_params_for(record)
    permitted = policy(record).permitted_attributes
    params.require(:user).permit(permitted)
  end

  def scrub_ids(attrs)
    if attrs.key?(:branch_ids)
      ids = Array(attrs[:branch_ids]).reject(&:blank?)
      attrs[:branch_ids] = policy_scope(Branch).where(id: ids).pluck(:id)
    end
    if attrs.key?(:role_ids)
      ids = Array(attrs[:role_ids]).reject(&:blank?)
      attrs[:role_ids] = policy_scope(Role).where(id: ids).pluck(:id)
    end
    attrs
  end

  def set_collections
    @branches = Branch.order(:name).pluck(:name, :id) # IDs, not public_ids, for HABTM
  end
end
