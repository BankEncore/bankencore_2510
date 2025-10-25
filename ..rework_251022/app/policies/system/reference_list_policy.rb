# app/policies/system/reference_list_policy.rb
# new
class System::ReferenceListPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.where(active: true)
  end
end
