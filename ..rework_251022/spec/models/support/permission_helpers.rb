# spec/models/support/permission_helpers.rb
# new
module PermissionHelpers
  def grant!(user, perm_key)
    p = Permission.find_or_create_by!(key: perm_key, name: perm_key.tr(".", " ").capitalize)
    r = Role.find_or_create_by!(key: "temp_#{perm_key}", name: "Temp #{perm_key}")
    RolePermission.find_or_create_by!(role: r, permission: p)
    UserRole.find_or_create_by!(user: user, role: r)
    user.reload
  end
end
RSpec.configure { |c| c.include PermissionHelpers }
