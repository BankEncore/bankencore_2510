# app/controllers/users_controller.rb
# new
class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = policy_scope(User).order(:email)
    authorize User
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = current_user
    authorize @user
    permitted = policy(@user).permitted_attributes
    attrs = params.require(:user).permit(permitted)

    if @user.update(attrs)
      redirect_to @user, notice: "Updated"
    else
      render :edit, status: :unprocessable_content
    end

    def set_user
      @user = User.find_by!(public_id: params[:public_id])
    end
  end
end
