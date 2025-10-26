# BankEncore Authorization Reference

_Last updated: October 2025_

## Roles

| Role | Description | Access Scope |
|------|--------------|---------------|
| **system_admin** | Full control of administrative and system data. | All admin areas, including `/admin/system/*`. Can manage users, branches, reference lists, and system codes. |
| **admin** | Operational administrator. | All `/admin/*` except system configuration or security functions reserved for `system_admin`. |
| **staff** | Authorized employee for daily operations. | Read/write for branch-level and payments resources. No system config access. |
| **user** | Standard application user or customer. | Public views and personal data only. No admin rights. |

---

## Policy Summary

| Policy | Applies To | Key Permissions |
|---------|-------------|----------------|
| **Admin::System::CountryPolicy** | `System::Country` | `index?`, `show?`, `create?`, `update?`, `destroy?` allowed for `system_admin` and `admin`. |
| **Admin::System::CurrencyPolicy** | `System::Currency` | Same as `CountryPolicy`; grants full management to admin roles. |
| **Admin::System::RegionPolicy** | `System::Region` | Region CRUD allowed for `system_admin` and `admin`; read-only for `staff`. |
| **Admin::System::CountryCurrencyPolicy** | `System::CountryCurrency` | Manages mapping between countries and currencies; restricted to system-level admins. |
| **Admin::System::NaicsCodePolicy** | `System::NaicsCode` | Allows listing, viewing, and editing of NAICS codes for `system_admin`; read-only for others. |
| **System::NaicsCodePolicy** | Public `/system/naics_codes` views | `index?` and `show?` allowed for all users; other actions restricted. |
| **Admin::BranchPolicy** | `Branch` model | `system_admin` and `admin` manage all; `staff` limited to their own branch. |
| **Admin::UserPolicy** | `User` model | Only `system_admin` may manage users. |
| **System::ReferenceListPolicy** | `System::ReferenceList` | Manageable by system-level roles only. |
| **System::ReferenceValuePolicy** | `System::ReferenceValue` | Same as above; `system_admin` full control, `staff` read-only. |

---

## Implementation Notes

- Authorization is handled via **Pundit**.  
- `ApplicationController` includes `Pundit::Authorization` and calls `authorize` or `policy_scope` for protected actions.  
- Specs exist under `spec/policies/admin/system/*` and `spec/system/*` verifying expected access patterns.  
- Helper methods such as `bypass_admin_auth!` and Devise test helpers are defined in `spec/support/warden_system.rb` and `spec/support/devise.rb`.  
- Default roles are seeded via the `User` model’s `role` enum (`system_admin`, `admin`, `staff`, `user`).

---

## Example: NAICS Access Flow

| Action | Route | Allowed Roles |
|---------|-------|---------------|
| `/system/naics_codes` | Public index | All users |
| `/system/naics_codes/:id` | Show details | All users |
| `/admin/system/naics_codes` | Admin index | system_admin, admin |
| `/admin/system/naics_codes/:id/edit` | Edit/update | system_admin only |
| NAICS import via `lib/tasks/naics.rake` | CLI | system_admin only |

---

## Testing Reference

| Area | File | Purpose |
|-------|------|---------|
| Policy specs | `spec/policies/admin/system/*` | Validate Pundit permissions per model |
| System specs | `spec/system/*_policy_spec.rb` | Simulate UI-level enforcement |
| Support helpers | `spec/support/warden_system.rb`, `spec/support/devise.rb` | Simplify auth setup in specs |
| Factories | `spec/factories/users.rb`, `spec/factories/branches.rb` | Generate test users and roles |

---

**Document owner:** Core Platform Team  
**Applies to:** BankEncore RBAC / Pundit authorization model
```
