# 2025-10-23 .. 2025-10-25
### CHANGELOG (auth + RBAC + admin integration)

#### **Added**

* **Authentication / Users**

  * Devise integration with confirmable, lockable, trackable.
  * Scoped user views under `users/*`.
  * Flash UX helper and improved `_flash` partial.
  * Development mailer using Letter Opener; dotenv boot order fixed.
  * `User` model fields: `name`, `time_zone`, `role`, `status`, MFA flags, terms accepted.
  * Indexes on `role`, `status`, `last_active_at`.

* **Authorization / RBAC**

  * Pundit policies for users, branches, system models.
  * `SystemAdminPolicy#access?` gate; uniform 403 handling.
  * Role and branch membership joins (`UserRole`, `BranchMembership`).
  * Policy scopes and permitted-attribute filtering in controllers.
  * Admin UI gating with `policy([:admin, model])`.

* **Admin Area**

  * `/admin` namespace with dashboard.
  * Full CRUD for Users and Branches (admin-only).
  * `/admin/system` CRUD for ReferenceLists, ReferenceValues, NaicsCodes, CountryCurrencies.
  * Pagy-based indexes and filters.
  * `public_id` stable IDs for admin models.
  * DaisyUI layouts and cards with policy visibility.

* **Models**

  * `Branch` model with status enum, contact/location fields, hours helpers, phone normalization.
  * `HasPublicId` concern and `to_param` support.
  * Updated System models for country/currency links and metadata validation.

* **Frontend**

  * `tom-select` integration for multi-select inputs.
  * Updated views for admin and public system resources.
  * Breadcrumbs and badges in NAICS pages.

* **Routing**

  * `resources :users, param: :public_id` in admin.
  * Admin/public namespaces for system resources.
  * Versioned NAICS paths (`system_naics_version_path`).

* **Seeds / Schema**

  * Consolidated `db/seeds/000_seeds.rb`; removed legacy files.
  * Ensured `system_admin` role grants `users.*`, `branches.*`, `admin.access`.
  * Refreshed schema and ACH routings columns.

* **Testing**

  * Updated factories for users, branches, roles, system lookups.
  * Request specs with Warden helpers and policy coverage.
  * Model specs for ACH routings and NAICS validations.
  * System specs use `driven_by(:rack_test)`.

#### **Changed**

* Unified 403 redirect for Pundit authorization failures.
* Controllers use policy scopes and strong params from policies.
* Cleaned autoload paths and config.
* Dashboard and navbar show admin links only when authorized.

#### **Removed / Breaking**

* Non-admin NAICS and CountryCurrency views deleted.
* `Payments::FrbDirectory` removed.
* Routes moved to admin namespace (endpoints changed).
* Deprecated AdminPolicy and old factories/specs pruned.

#### **Security / Ops**

* All admin areas require `admin.access`.
* Parameter tampering on roles/branches blocked via scoped assignments.
* Run `bin/rails db:migrate` then `bin/rails db:seed` to refresh roles and permissions.
* Ensure `phonelib` initializer present for phone helpers.

#### **Result**

Authentication, RBAC, and admin management are fully functional; model and request specs pass; admin UI and policies consistent.


# 2025-10-21 … 2025-10-22

## Authentication and RBAC

* Add Devise with confirmable, lockable, trackable; generated user-scoped views.
* User model: `admin` flag, `system_admin?` shim, enums `role_i` and `status`; associations to branches via memberships. 
* Admin navbar link gated by `AdminDashboardPolicy#index?`. 

## Authorization (Pundit)

* Base `ApplicationPolicy` default-deny; user, branch, and admin policies.
* Admin layer: `AdminPolicy` (`access?` via `role_system_admin?`), `Admin::UserPolicy`, `Admin::BranchPolicy` with scopes.
* System policies for Reference Lists/Values, NAICS, Country Currencies, plus `SystemAdminPolicy`. 

## Admin UI and Routes

* Admin dashboard with counts tiles for Users, Branches, System data, and ACH. 
* Admin CRUD: Users, Branches. Public read for branches remains. 
* System Admin namespace: CRUD for Reference Lists and Values, NAICS, Country↔Currency; public read-only controllers for lists/values kept. Legacy numeric-ID redirects to public_id. 

## Payments · ACH

* Public index/show for `Payments::AchRouting` with Pagy filters; show FRB details panel.
* Admin CRUD for ACH routings under `Admin::Payments`.
* FRB directory moved to simple in-repo lookup.
* Model normalizes routing numbers, sets defaults, exposes flags and FRB branch helper. 

## System Data Models

* Reference Lists/Values with validations, ordering, optional per-list metadata contract, and `public_id` routing via `HasPublicId`. 
* NAICS Code model: hierarchy helpers, validations, derived fields, admin and public views. 
* Country, Currency, CountryCurrency mapping with validity windows and admin CRUD. 

## Branches

* `Branch` model with `public_id`, statuses, validations.
* Public index/show; Admin full CRUD. 

## UI/Frontend

* Tailwind+daisyUI layout, navbar with Admin link gating, flash helper and partial, theme switcher with localStorage, Stimulus controllers including Tom Select. 

## Jobs/Mailers

* Base `ApplicationJob`.
* `ApplicationMailer` and Devise mailer views. 

## Migrations and Schema

* Present in snapshot: `20251017022102_enable_pgcrypto.rb` and `20251017022110_base_schema.rb`. These appear to codify UUID support and base tables including Devise users and system tables. No separate incremental “add_*” migrations are present in this snapshot. 

## Breaking changes called out by commits and reflected here

* Admin-scoped routes for NAICS and CountryCurrencies; non-admin edit/new forms removed.
* Legacy Payments::FrbDirectory library replaced by in-app constant. 
