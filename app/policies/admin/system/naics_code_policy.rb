# app/policies/admin/system/naics_code_policy.rb
class Admin::System::NaicsCodePolicy < ApplicationPolicy
  def index? = user&.can?("system.read") || user&.can?("naics.read") || user&.rbac_role?("sysadmin")
  def show?  = index?

  class Scope < Scope
    def resolve
      return scope.none unless index?
      scope.all
    end

    private

    def index?
      user&.can?("system.read") || user&.can?("naics.read") || user&.rbac_role?("sysadmin")
    end
  end
end
