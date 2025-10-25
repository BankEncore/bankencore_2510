# app/models/user_role.rb
# new
class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  has_many :branch_memberships, dependent: :destroy
  has_many :branches, through: :branch_memberships
  validates :user_id, uniqueness: { scope: :role_id }
end
