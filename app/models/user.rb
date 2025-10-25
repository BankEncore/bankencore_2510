# app/models/user.rb
# new
class User < ApplicationRecord
  def to_param = public_id
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :confirmable, :lockable, :validatable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :permissions, through: :roles
  has_many :branch_memberships, dependent: :destroy
  has_many :users, through: :branch_memberships
  has_many :branches, through: :branch_memberships

  before_validation do
    self.first_name = first_name&.strip
    self.last_name  = last_name&.strip
    self.display_name = display_name&.strip.presence || [ first_name, last_name ].compact.join(" ").squeeze(" ")
    self.locale = locale&.strip
    self.phone_e164 = phone_e164&.strip
  end

  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
  validates :display_name, length: { maximum: 150 }, allow_nil: true
  validates :locale, format: { with: /\A[a-z]{2}(?:-[A-Z]{2})?\z/ }, allow_blank: true
  validates :phone_e164, format: { with: /\A\+\d{7,15}\z/ }, allow_blank: true

  # RBAC
  def system_admin? = can?("admin.access")
  def can?(perm_key) = permissions.exists?(key: perm_key.to_s)
  def full_name = "#{first_name} #{last_name}".squeeze(" ").strip
end
