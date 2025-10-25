# app/policies/system/currency_policy.rb
# new
class System::CurrencyPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  class Scope < Scope
    def resolve = @scope.where(active: true)
  end
end
