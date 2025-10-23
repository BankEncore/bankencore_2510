# app/policies/admin/user_policy.rb
# new
class Admin::UserPolicy < ApplicationPolicy
  def index? = can?("users.read")
  def show?  = can?("users.read")
  def create? = can?("users.write")
  def update? = can?("users.write")
  def destroy? = can?("users.write")
  class Scope < Scope
    def resolve = can?("users.read") ? @scope.all : @scope.none
  end
end
