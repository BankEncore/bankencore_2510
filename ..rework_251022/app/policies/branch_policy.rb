# app/policies/branch_policy.rb
# new
class BranchPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.where(status: 1)
  end
end