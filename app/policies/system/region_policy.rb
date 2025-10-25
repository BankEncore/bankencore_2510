# app/policies/system/region_policy.rb
# new
class System::RegionPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.where(active: true)
  end
end
