# app/models/branch_membership.rb
class BranchMembership < ApplicationRecord
  belongs_to :user
  belongs_to :branch
  validates :user_id, uniqueness: { scope: :branch_id }
end
