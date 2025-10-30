# app/policies/admin/dashboard_policy.rb
class Admin::DashboardPolicy < Struct.new(:user, :dashboard)
  def index?
    user&.can?("admin.access") || user&.rbac_role?("sysadmin")
  end
end
