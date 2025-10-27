class Admin::BasePolicy < ApplicationPolicy
  def admin_access? = user&.can?("admin.access")
  class Scope < ApplicationPolicy::Scope
    def resolve = admin_access? ? scope.all : scope.none
  end
end
