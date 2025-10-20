# app/policies/system/reference_list_policy.rb
class System::CountryCurrencyPolicy < ApplicationPolicy
  def index? = user&.system_admin?
  def show?  = user&.system_admin?
  def create? = user&.system_admin?
  def update? = user&.system_admin?
  def destroy? = user&.system_admin?
  class Scope < Scope
    def resolve = scope.all
  end
end
# duplicate pattern for ReferenceValue, NaicsCode, CountryCurrency
