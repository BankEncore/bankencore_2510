# db/seeds/000_seeds.rb
# new
# Countries
System::Country.upsert_all([
  { alpha2: "US", alpha3: "USA", numeric: "840", iso_short_name: "United States of America", dialing_prefix: "1", currency_primary_code: "USD" },
  { alpha2: "CA", alpha3: "CAN", numeric: "124", iso_short_name: "Canada", dialing_prefix: "1", currency_primary_code: "CAD" },
  { alpha2: "FR", alpha3: "FRA", numeric: "250", iso_short_name: "France", dialing_prefix: "33", currency_primary_code: "EUR" }
], unique_by: :alpha2)

# Regions
System::Region.upsert_all([
  { country_alpha2: "US", region_code: "PA", name: "Pennsylvania", kind: "state", iso_code: "US-PA" },
  { country_alpha2: "CA", region_code: "ON", name: "Ontario",      kind: "province", iso_code: "CA-ON" },
  { country_alpha2: "FR", region_code: "75", name: "Paris",        kind: "department", iso_code: "FR-75" }
], unique_by: %i[country_alpha2 region_code])

# Currencies
System::Currency.upsert_all([
  { code: "USD", numeric: "840", name: "US Dollar", full_name: "United States dollar", minor_units: 2, symbol: "$", unicode_codepoint: 36 },
  { code: "CAD", numeric: "124", name: "Canadian Dollar", full_name: "Canadian dollar", minor_units: 2, symbol: "$", unicode_codepoint: 36 },
  { code: "EUR", numeric: "978", name: "Euro", full_name: "Euro", minor_units: 2, symbol: "€", unicode_codepoint: 8364 }
], unique_by: :code)

# Country↔Currency
System::CountryCurrency.upsert_all([
  { country_alpha2: "US", currency_code: "USD", is_primary: true,  legal_tender: true },
  { country_alpha2: "CA", currency_code: "CAD", is_primary: true,  legal_tender: true },
  { country_alpha2: "FR", currency_code: "EUR", is_primary: true,  legal_tender: true }
], unique_by: %i[country_alpha2 currency_code])

# Roles
roles = {
  viewer: "Read-only access",
  staff: "Standard staff",
  system_admin: "Full admin"
}
roles.each { |k, v| Role.upsert({ key: k.to_s, name: v, created_at: Time.current, updated_at: Time.current }, unique_by: :key) }

# Permissions (sample)
perms = %w[
  users.read users.write
  branches.read branches.write
  system.read system.write
  admin.access
]
perms.each { |k| Permission.upsert({ key: k, name: k.tr(".", " ").capitalize, created_at: Time.current, updated_at: Time.current }, unique_by: :key) }

# Role→Permission map
map = {
  viewer: %w[users.read branches.read system.read],
  staff:  %w[users.read branches.read system.read branches.write],
  system_admin: %w[users.read users.write branches.read branches.write system.read system.write admin.access]
}
map.each do |role_key, perm_keys|
  role = Role.find_by!(key: role_key.to_s)
  Permission.where(key: perm_keys).pluck(:id).each do |pid|
    RolePermission.upsert({ role_id: role.id, permission_id: pid, created_at: Time.current, updated_at: Time.current },
                          unique_by: %i[role_id permission_id])
  end
end

# Branches
Branch.upsert_all([
  {
    code: "001", name: "Main Office", status: 1, time_zone: "America/New_York",
    address_1: "100 Market St", city: "Pittsburgh", region_code: "PA", postal_code: "15222",
    country_alpha2: "US", email: "main@bankencore.test",
    operating_hours: { tz: "America/New_York", weekly: [], exceptions: [] }
  },
  {
    code: "002", name: "East Side", status: 1, time_zone: "America/New_York",
    address_1: "200 Liberty Ave", city: "Pittsburgh", region_code: "PA", postal_code: "15222",
    country_alpha2: "US", email: "east@bankencore.test",
    operating_hours: { tz: "America/New_York", weekly: [], exceptions: [] }
  }
], unique_by: :code)

# Users (confirmed) + passwords
admin_pwd  = ENV["SEED_ADMIN_PASSWORD"]  || "ChangeMeAdmin123!"
staff_pwd  = ENV["SEED_STAFF_PASSWORD"]  || "ChangeMeStaff123!"
viewer_pwd = ENV["SEED_VIEWER_PASSWORD"] || "ChangeMeViewer123!"

def upsert_user(email:, first_name:, last_name:, pwd:)
  u = User.find_or_initialize_by(email: email.downcase)
  u.first_name = first_name
  u.last_name  = last_name
  u.display_name = "#{first_name} #{last_name}"
  u.time_zone = "America/New_York"
  u.locale = "en-US"
  u.password = pwd
  u.password_confirmation = pwd
  u.confirmed_at ||= Time.current
  u.save!
  u
end

admin  = upsert_user(email: "admin@example.com",  first_name: "System",  last_name: "Admin",  pwd: admin_pwd)
staff  = upsert_user(email: "staff@example.com",  first_name: "Support", last_name: "Staff",  pwd: staff_pwd)
viewer = upsert_user(email: "viewer@example.com", first_name: "Sample",  last_name: "Viewer", pwd: viewer_pwd)

# Assign roles
{
  admin  => :system_admin,
  staff  => :staff,
  viewer => :viewer
}.each do |user, role_key|
  role = Role.find_by!(key: role_key.to_s)
  UserRole.upsert({ user_id: user.id, role_id: role.id, created_at: Time.current, updated_at: Time.current },
                  unique_by: %i[user_id role_id])
end

# Memberships: admin → all branches; others → 001
b001 = Branch.find_by!(code: "001")
Branch.find_each { |b| BranchMembership.upsert({ user_id: admin.id, branch_id: b.id, created_at: Time.current, updated_at: Time.current }, unique_by: %i[user_id branch_id]) }
[ staff, viewer ].each { |u| BranchMembership.upsert({ user_id: u.id, branch_id: b001.id, created_at: Time.current, updated_at: Time.current }, unique_by: %i[user_id branch_id]) }

puts "Seed complete."
