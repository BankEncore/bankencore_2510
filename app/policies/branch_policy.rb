# app/policies/branch_policy.rb
class BranchPolicy < ApplicationPolicy
  def index?  = true         # or user.present? if you want only logged-in
  def show?   = true
  def create? = user&.admin?
  def update? = user&.admin?
  def destroy? = user&.admin?

  class Scope < Scope
    def resolve
      scope.all               # or whatever visibility is appropriate
    end
  end
end
