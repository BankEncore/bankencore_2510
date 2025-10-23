# app/policies/system/reference_value_policy.rb
# new
class System::ReferenceValuePolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.where(active: true)
  end
end
