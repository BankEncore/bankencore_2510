# app/policies/admin_policy.rb
class AdminPolicy < ApplicationPolicy
  def access?
    user&.role_system_admin?
  end
end
