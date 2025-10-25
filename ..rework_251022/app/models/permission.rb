# app/models/permission.rb
# new
class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :restrict_with_exception
  has_many :roles, through: :role_permissions
  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
