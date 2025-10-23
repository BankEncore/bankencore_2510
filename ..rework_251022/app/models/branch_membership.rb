# app/models/branch_membership.rb
# new
class BranchMembership < ApplicationRecord
  belongs_to :user,   inverse_of: :branch_memberships
  belongs_to :branch, inverse_of: :branch_memberships

  validates :user, :branch, presence: true
  validates :branch_id, uniqueness: { scope: :user_id }

  # Scopes
  scope :for_user,   ->(u) { where(user_id: u.is_a?(User) ? u.id : u) }
  scope :for_branch, ->(b) { where(branch_id: b.is_a?(Branch) ? b.id : b) }

  # Convenience
  delegate :code, :name, to: :branch, prefix: true, allow_nil: true
end
