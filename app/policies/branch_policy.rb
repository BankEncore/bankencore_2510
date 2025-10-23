# app/policies/branch_policy.rb
class BranchPolicy < ApplicationPolicy
  def index?  = user.can?("branches.read")  || user.can?("admin.access")
  def show?   = index?
  def new?    = create?
  def create? = user.can?("branches.write") || user.can?("admin.access")
  def edit?   = update?
  def update? = user.can?("branches.write") || user.can?("admin.access")
  def destroy? = user.can?("branches.admin") || user.can?("admin.access")

  class Scope < Scope
    def resolve
      user.can?("branches.read") || user.can?("admin.access") ? scope.all : scope.none
    end
  end
end
