# app/policies/admin/branch_policy.rb
class Admin::BranchPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve = user.admin? ? scope.all : scope.none
  end

  def index?   = user.admin?
  def show?    = user.admin?
  def create?  = user.admin?
  def update?  = user.admin?
  def destroy? = user.admin?
end
