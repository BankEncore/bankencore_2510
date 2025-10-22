# app/policies/admin_dashboard_policy.rb
class AdminDashboardPolicy < ApplicationPolicy
  def index?
    user&.admin? # or: user.roles.include?("admin")
  end
end
