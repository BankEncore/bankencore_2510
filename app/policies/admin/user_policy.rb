# app/policies/admin/user_policy.rb
class Admin::UserPolicy < ApplicationPolicy
  def index?;  user&.admin?; end
  def show?;   user&.admin?; end
  def create?; user&.admin?; end
  def update?; user&.admin?; end
  def destroy?; user&.admin?; end

  def permitted_attributes
    base = [ :email, :name, :time_zone, { branch_ids: [] } ]
    user&.admin? ? base + [ :admin, :status, :role_i ] : base
  end

  class Scope < Scope
    def resolve
      user&.admin? ? scope.all : scope.none
    end
  end
end
