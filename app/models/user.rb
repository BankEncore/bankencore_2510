# app/models/user.rb
class User < ApplicationRecord
  # URLs use public_id when present
  def to_param = public_id.presence || id.to_s

  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :confirmable, :lockable, :validatable

  # Associations
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :permissions, through: :roles

  has_many :branch_memberships, dependent: :destroy
  has_many :branches, through: :branch_memberships
  # (removed invalid: has_many :users, through: :branch_memberships)

  # Normalization
  before_validation do
    self.first_name   = first_name&.strip
    self.last_name    = last_name&.strip
    self.display_name = display_name&.strip.presence ||
                        [ first_name, last_name ].compact.join(" ").squeeze(" ").presence
    self.locale       = locale&.strip
    self.phone_e164   = phone_e164&.strip
  end

  # Validations
  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
  validates :display_name, length: { maximum: 150 }, allow_nil: true
  validates :locale, format: { with: /\A[a-z]{2}(?:-[A-Z]{2})?\z/ }, allow_blank: true
  validates :phone_e164, format: { with: /\A\+\d{7,15}\z/ }, allow_blank: true

  # RBAC helpers (works with your Roles/Permissions tables)
  def can?(perm_key)
    return false unless association_present?(:permissions)
    permissions.exists?(key: perm_key.to_s)
  end

  def system_admin?
    rbac_role?("sysadmin") || rbac_perm?("admin.access")
  end

  def staff?      = rbac_role?("staff")
  def onboarding? = rbac_role?("onboarding")
  def operations? = rbac_role?("operations")

  def full_name = "#{first_name} #{last_name}".squeeze(" ").strip

  private

  def rbac_role?(key)
    return false unless association_present?(:roles)
    roles.where(key: key).exists?
  end

  def rbac_perm?(key)
    return false unless association_present?(:permissions)
    permissions.where(key: key).exists?
  end

  def association_present?(name)
    self.class.reflect_on_association(name).present?
  end
end
