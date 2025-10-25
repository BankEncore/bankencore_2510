# app/policies/admin_dashboard_policy.rb
# new
class AdminDashboardPolicy < ApplicationPolicy
  def index? = can?("admin.access")
end
