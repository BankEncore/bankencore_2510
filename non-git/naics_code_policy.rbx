# app/policies/admin/system/naics_code_policy.rb
class Admin::System::NaicsCodePolicy < Admin::BasePolicy
  def index? = can?("admin.access") && can?("system.read")
  def show?  = index?

  class Scope < Scope
    def resolve = (user&.can?("admin.access") && user&.can?("system.read")) ? scope.all : scope.none
  end
end
