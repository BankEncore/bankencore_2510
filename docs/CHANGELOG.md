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
