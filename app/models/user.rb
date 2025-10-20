# app/models/user.rb
class User < ApplicationRecord
  attribute :admin, :boolean, default: false  # optional but safe

  def system_admin?
    ActiveModel::Type::Boolean.new.cast(self[:admin])
  end

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :lockable, :trackable

  has_many :branch_memberships, dependent: :destroy
  has_many :branches, through: :branch_memberships

  enum :role_i, { read_only: 0, staff: 1, system_admin: 2 }, prefix: :role
  enum :status, { active: "active", suspended: "suspended", invited: "invited" }, validate: true
  validates :role, inclusion: { in: %w[user admin auditor support] }
end
