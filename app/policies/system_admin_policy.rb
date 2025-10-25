class SystemAdminPolicy < ApplicationPolicy
  # used via policy(:system_admin).access?
  def access?
    user&.system_admin?
  end
end
