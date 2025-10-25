# app/policies/system/country_policy.rb
# new
class System::CountryPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.where(active: true)
  end
end
