# app/policies/admin/system/reference_list_policy.rb
# new
class Admin::System::ReferenceListPolicy < ApplicationPolicy
  # reads require system.read, writes require system.write

  def index?  = can?("system.read")
  def show?   = can?("system.read")
  def create? = can?("system.write")
  def update? = can?("system.write")
  def destroy? = can?("system.write")
  def new?    = create?
  def edit?   = update?

  class Scope < Scope
    def resolve
      can?("system.read") ? @scope.all : @scope.none
    end
  end
end
