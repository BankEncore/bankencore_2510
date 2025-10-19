# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :lockable, :trackable

  enum :status, { active: "active", suspended: "suspended", invited: "invited" }, validate: true
  validates :role, inclusion: { in: %w[user admin auditor support] }
end
