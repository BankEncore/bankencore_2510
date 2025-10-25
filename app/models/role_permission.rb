# app/models/role_permission.rb
# new
class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission
  validates :role_id, uniqueness: { scope: :permission_id }
end
