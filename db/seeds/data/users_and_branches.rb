# db/seeds/data/users_and_branches.rb
ActiveRecord::Base.transaction do
  now = Time.current

  # --- branches -------------------------------------------------------------
  rows = [
    { code: "001", name: "Main Office",       status: "active" },
    { code: "002", name: "West Philly",       status: "active" },
    { code: "003", name: "Ardmore",           status: "active" },
    { code: "101", name: "Cherry Hill",       status: "active" },
    { code: "999", name: "Operations Center", status: "active" }
  ].map { _1.merge(created_at: now, updated_at: now) }
  Branch.upsert_all(rows, unique_by: :index_branches_on_code)
  by_code = Branch.where(code: rows.map { _1[:code] }).index_by(&:code)

  # --- users ----------------------------------------------------------------
  admin_pw = ENV.fetch("ADMIN_PASSWORD", "ChangeMe123!")
  user_pw  = ENV.fetch("USER_PASSWORD",  "ChangeMe123!")
  reset_pw = ENV.fetch("RESET_SEED_PASSWORDS", "1") == "1" # set to "0" to preserve existing

  def apply_common_user_attrs!(u)
    u.time_zone = "UTC" if u.has_attribute?(:time_zone)
    u.status    = "active" if u.has_attribute?(:status)
    # map role_i enum precisely
    if (enums = u.class.defined_enums) && enums["role_i"]
      u.role_i = :system_admin if u.email == "admin@example.com"
      u.role_i = :read_only    if u.email == "user@example.com"
    end
    u.role  = "admin" if u.has_attribute?(:role) && u.email == "admin@example.com"
    u.role  = "user"  if u.has_attribute?(:role) && u.email == "user@example.com"
    u.admin = (u.email == "admin@example.com") if u.has_attribute?(:admin)
  end

  def reset_security_fields!(u)
    # lockable
    u.failed_attempts = 0 if u.has_attribute?(:failed_attempts)
    u.locked_at = nil     if u.has_attribute?(:locked_at)
    u.unlock_token = nil  if u.has_attribute?(:unlock_token)
    # recoverable
    u.reset_password_token = nil if u.has_attribute?(:reset_password_token)
    u.reset_password_sent_at = nil if u.has_attribute?(:reset_password_sent_at)
    # confirmable (not in BaseSchema, but safe if present)
    if u.has_attribute?(:confirmed_at)
      u.confirmed_at = Time.current
      u.confirmation_token = nil     if u.has_attribute?(:confirmation_token)
      u.confirmation_sent_at = nil   if u.has_attribute?(:confirmation_sent_at)
      u.unconfirmed_email = nil      if u.has_attribute?(:unconfirmed_email)
    end
  end

  admin = User.find_or_initialize_by(email: "admin@example.com")
  if admin.new_record? || reset_pw
    admin.password = admin_pw
    admin.password_confirmation = admin_pw
  end
  apply_common_user_attrs!(admin)
  reset_security_fields!(admin)
  admin.save!

  user = User.find_or_initialize_by(email: "user@example.com")
  if user.new_record? || reset_pw
    user.password = user_pw
    user.password_confirmation = user_pw
  end
  apply_common_user_attrs!(user)
  reset_security_fields!(user)
  user.save!

  def force_confirm!(u, at = Time.current)
    cols = u.class.column_names
    return unless cols.include?("confirmed_at")
    u.update_columns(confirmed_at: at, confirmation_token: nil,
                    confirmation_sent_at: nil, unconfirmed_email: nil)
  end

  force_confirm!(admin)
  force_confirm!(user)

  # --- memberships ----------------------------------------------------------
  [[admin, %w[001 002 003 101 999]], [user, %w[001]]].each do |u, codes|
    codes.each do |code|
      b = by_code.fetch(code)
      BranchMembership.find_or_create_by!(user_id: u.id, branch_id: b.id)
    end
  end

  puts "Users seeded: #{User.where(email: %w[admin@example.com user@example.com]).count}"
  puts "Branches seeded: #{Branch.count}"
  puts "Memberships: #{BranchMembership.count}"
end
