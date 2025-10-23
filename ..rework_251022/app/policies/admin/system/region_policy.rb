# app/policies/admin/system/region_policy.rb
# new
class Admin::System::RegionPolicy < ApplicationPolicy
  def index? = can?("system.read")
  def show?  = can?("system.read")
  def create? = can?("system.write")
  def update? = can?("system.write")
  def destroy? = can?("system.write")
  class Scope < Scope
    def resolve = can?("system.read") ? @scope.all : @scope.none
  end
end
