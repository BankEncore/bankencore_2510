# new
class Role < ApplicationRecord
  has_many :user_roles, dependent: :restrict_with_exception
  has_many :users, through: :user_roles
  has_many :role_permissions, dependent: :restrict_with_exception
  has_many :permissions, through: :role_permissions
  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
