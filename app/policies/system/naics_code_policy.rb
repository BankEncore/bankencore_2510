# app/policies/system/naics_code_policy.rb
class System::NaicsCodePolicy < ApplicationPolicy
  def index?  = user&.system_admin?
  def show?   = user&.system_admin?
  def create? = user&.system_admin?
  def update? = user&.system_admin?
  def destroy? = user&.system_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
