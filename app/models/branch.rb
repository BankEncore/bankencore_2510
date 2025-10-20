# app/models/branch.rb
class Branch < ApplicationRecord
  include HasPublicId
  has_many :branch_memberships, class_name: "BranchMembership", dependent: :destroy
  has_many :users, through: :branch_memberships
  STATUSES = %w[active inactive closed].freeze
  validates :code, presence: true, uniqueness: true, length: { maximum: 10 }, format: { with: /\A[0-9A-Za-z_-]+\z/ }
  validates :name, presence: true, length: { maximum: 100 }
  validates :status, inclusion: { in: STATUSES }
  def to_param = public_id || id.to_s
end
