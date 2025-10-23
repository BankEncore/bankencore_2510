# app/policies/system/naics_code_policy.rb
# new
class System::NaicsCodePolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.where(active: true)
  end
end
