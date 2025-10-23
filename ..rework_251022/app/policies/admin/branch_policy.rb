# app/policies/admin/branch_policy.rb
# new
class Admin::BranchPolicy < ApplicationPolicy
  def index? = can?("branches.read")
  def show?  = can?("branches.read")
  def create? = can?("branches.write")
  def update? = can?("branches.write")
  def destroy? = can?("branches.write")
  class Scope < Scope
    def resolve = can?("branches.read") ? @scope.all : @scope.none
  end
end
