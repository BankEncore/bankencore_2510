# app/policies/branch_policy.rb
class BranchPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve = scope.all
  end

  def index? = true
  def show?  = true

  # public controller is read-only
  def create? = false
  def update? = false
  def destroy? = false
end


