ActiveRecord::Base.transaction do
  now = Time.current

  Branch.upsert_all(
    [
      { code: "001", name: "Main Office",       status: "active", created_at: now, updated_at: now },
      { code: "002", name: "West Philly",       status: "active", created_at: now, updated_at: now },
      { code: "003", name: "Ardmore",           status: "active", created_at: now, updated_at: now },
      { code: "101", name: "Cherry Hill",       status: "active", created_at: now, updated_at: now },
      { code: "999", name: "Operations Center", status: "active", created_at: now, updated_at: now }
    ],
    unique_by: :index_branches_on_code
  )
  by_code = Branch.where(code: %w[001 002 003 101 999]).index_by(&:code)

  admin = User.find_or_create_by!(email: "admin@example.com") { |u| u.password = u.password_confirmation = "ChangeMe123!" }
  user  = User.find_or_create_by!(email: "user@example.com")  { |u| u.password = u.password_confirmation = "ChangeMe123!" }

  admin.update!(admin: true, role: "admin", role_i: :system_admin)
  user.update!(admin: false, role: "user", role_i: :read_only)

  [[admin, %w[001 002 003 101 999]], [user, %w[001]]].each do |u, codes|
    codes.each { |code| BranchMembership.find_or_create_by!(user_id: u.id, branch_id: by_code.fetch(code).id) }
  end
  def force_confirm!(u, at = Time.current)
  cols = u.class.column_names
  return unless cols.include?("confirmed_at")
    u.update_columns(
      confirmed_at: at,
      confirmation_token: nil,
      confirmation_sent_at: nil,
      unconfirmed_email: nil
    )
  end

  force_confirm!(admin)
  force_confirm!(user)
end
