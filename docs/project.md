# BankEncore – Implementation To-Do (Current Goals)

## 0) Preparation
- [ ] Create `feature/auth-rbac-admin` branch.
- [ ] Enable CI on PRs from feature branches.
- [ ] Add `.env.example` with Devise mailer host vars.

## 1) Authentication (Devise)
- [ ] Add gems: `devise`, `pundit`, `audited` or `paper_trail`.
- [ ] `rails g devise:install` and set mailer URLs per env.
- [ ] `rails g devise User`.
- [ ] Add user attrs: role enum, first/last name, time_zone.
- [ ] `before_action :authenticate_user!` in `ApplicationController`.
- [ ] Seed first admin user; document recovery flow.
**Done when:** Sign in/out works. New app requires login.

## 2) RBAC (Pundit)
- [ ] `rails g pundit:install`.
- [ ] Add global rescue for `Pundit::NotAuthorizedError` → 403 page.
- [ ] Add `enum :role, { read_only:0, staff:1, system_admin:2 }` with prefix.
- [ ] `ApplicationPolicy` created; default deny.
- [ ] Policy specs for base rules.
**Done when:** Non-admins blocked from admin routes.

## 3) Branches
- [ ] Create `branches` table (code unique, name, status).
- [ ] Create `branch_memberships` (user_id, branch_id, unique index).
- [ ] Add optional `branch_id` to `parties` (FK).
- [ ] Models: `Branch`, `BranchMembership`; associations on `User`, `Party`.
- [ ] Seeds: “001 Main Office”.
- [ ] Routes: read-only `branches#index/show`; admin CRUD under `/admin/branches`.
- [ ] Pundit policies and request specs.
**Done when:** Admin can CRUD branches. Users can be assigned to branches.

## 4) Admin Layer for System References
- [ ] Keep existing System models (`ReferenceList`, `ReferenceValue`, `NaicsCode`, `CountryCurrency`).
- [ ] Add `/admin/system` namespace with CRUD controllers:
  - `Admin::System::ReferenceListsController`
  - `Admin::System::ReferenceValuesController`
  - `Admin::System::NaicsCodesController`
  - `Admin::System::CountryCurrenciesController`
- [ ] Restrict all to `system_admin` via Pundit policies.
- [ ] Move write forms to `app/views/admin/system/...`; keep public reads only.
- [ ] Standardize identifiers: prefer `public_id` + `to_param`.
- [ ] Add audits on reference models.
**Done when:** Admin can manage references; public reads unaffected.

## 5) Routing and Controller Hygiene
- [ ] Ensure all non-admin write actions removed from public namespaces.
- [ ] Add `admin_root` dashboard.
- [ ] Align `:id` vs `:public_id` across System routes; add redirects if changed.
- [ ] Payments ACH controllers authorized; index/show remain readable.
**Done when:** No write paths exist outside `/admin`.

## 6) View Helpers and Consumer Use
- [ ] Add helpers:
  - `ref_options(key)` and `ref_label(key, code)`.
  - Cache with list version.
- [ ] Replace hardcoded selects in consumer forms with `ref_options`.
- [ ] Show pages render labels via `ref_label`.
- [ ] Optional: ViewComponent `<RefSelect key=...>` for DRY UI.
**Done when:** All consumer forms pull options from references.

## 7) Seeds and Data Ops
- [ ] Versioned seeds for references and branches.
- [ ] Rake task: `refs:load[version]` and `branches:seed`.
- [ ] Document regeneration of cache/version after updates.
**Done when:** Fresh env can seed and boot fully.

## 8) Security, Audits, and Errors
- [ ] Add 401/403 pages and layouts.
- [ ] Enable audit trail on admin models (or PaperTrail versions).
- [ ] Log admin actions with user id and request id.
**Done when:** Unauthorized paths are handled. Changes are auditable.

## 9) CI and Quality Gates
- [ ] GitHub Actions: Ruby setup, RSpec, Brakeman, Importmap audit.
- [ ] Minimum coverage gate for `models`, `policies`, `requests`.
**Done when:** CI green on PR. Security scanners run.

## 10) Tests
- [ ] Model specs: validations for `Branch`, `Reference*`.
- [ ] Policy specs: admin vs non-admin for each admin controller.
- [ ] Request specs: admin CRUD happy paths and 403s.
- [ ] System specs: sign-in, navigate to admin, create reference value.
**Done when:** Tests pass and cover critical paths.

## 11) Migration and Backfill Strategy
- [ ] Keep `parties.branch_id` nullable now.
- [ ] Backfill plan doc for assigning branches to legacy parties.
- [ ] Prepare future migration to enforce NOT NULL where required.
**Done when:** Plan documented; schema supports gradual rollout.

## 12) Docs and Ops
- [ ] Update `README` with setup, seeds, roles.
- [ ] Add “Admin Guide” for maintaining references and branches.
- [ ] Add “Access Model” doc explaining user↔branch↔policies.
**Done when:** New dev can follow docs to working admin.

---

### Command Hints
- Create controllers:  
  `rails g controller admin/system/reference_lists index new edit show`  
  `rails g controller admin/system/reference_values index new edit show`  
  `rails g controller admin/branches`
- Policies:  
  `rails g pundit:policy admin/system/reference_list`  
  `rails g pundit:policy admin/system/reference_value`  
  `rails g pundit:policy admin/branch`

**Milestone exit:** Auth on by default. RBAC enforced. Branches live with memberships. Admin system references writable only under `/admin/system`. Consumer views use helpers. CI and audits active.

---

## Milestone: Foundation: Access Control and Administration

### Authentication
1) Add Devise and scaffold auth
- Labels: area/auth, type/feature
- Accept: Users can sign up, sign in, sign out.
- Tasks:
  - Add gems and run installers
  - Generate User
  - Configure mailer URLs per env

2) Seed initial system admin
- Labels: area/auth, type/chore, security
- Accept: One admin exists after `rails db:seed`.
- Tasks:
  - Seed script with secure random password
  - README note for first login

3) Require login globally
- Labels: area/auth, type/change
- Accept: All routes require auth except health/root (as configured).
- Tasks:
  - `before_action :authenticate_user!`
  - Allowlist public endpoints

### RBAC
4) Install Pundit and base policy
- Labels: area/rbac, type/feature
- Accept: Pundit wired; default deny.
- Tasks:
  - Install
  - `ApplicationPolicy`
  - Global rescue → 403

5) Add role enum to User
- Labels: area/rbac, type/change
- Accept: `read_only`, `staff`, `system_admin` available with predicate helpers.
- Tasks:
  - Migration and model enum
  - Backfill default

6) Policy specs baseline
- Labels: area/rbac, type/test
- Accept: Specs cover allow/deny for base rules.
- Tasks:
  - Model and policy spec scaffolds

### Branches
7) Create Branch model and migration
- Labels: area/branches, type/feature
- Accept: `branches` table with unique `code`, `name`, `status`.
- Tasks:
  - Migration + model
  - Validations + enum for status

8) Create BranchMembership (Users ↔ Branches)
- Labels: area/branches, type/feature
- Accept: Many-to-many works; unique pair enforced.
- Tasks:
  - Migration + model
  - Assocs on User and Branch

9) Link Parties to Branch (nullable)
- Labels: area/branches, type/change
- Accept: `parties.branch_id` exists with FK.
- Tasks:
  - Migration
  - Minimal model association

10) Seed default branch(es)
- Labels: area/branches, type/chore
- Accept: “001 Main Office” present post-seed.
- Tasks:
  - Seed
  - README update

11) Admin CRUD for Branches
- Labels: area/branches, area/admin, type/feature
- Accept: `/admin/branches` full CRUD, Pundit-guarded.
- Tasks:
  - Controller, views, routes
  - Policy + request specs

### Admin System References
12) Create `/admin/system` namespace
- Labels: area/admin, type/feature
- Accept: Admin dashboard reachable at `/admin`.
- Tasks:
  - Route mount
  - Minimal dashboard page

13) Admin CRUD: ReferenceLists
- Labels: area/admin, area/references, type/feature
- Accept: Lists CRUD under `/admin/system/reference_lists`.
- Tasks:
  - Controller, views
  - Policy + request specs

14) Admin CRUD: ReferenceValues
- Labels: area/admin, area/references, type/feature
- Accept: Values CRUD under lists; shallow routes OK.
- Tasks:
  - Controller, views
  - Policy + request specs

15) Admin CRUD: NAICS Codes
- Labels: area/admin, area/references, type/feature
- Accept: NAICS maintainable under admin; public read routes unchanged.
- Tasks:
  - Controller, views
  - Policy + request specs

16) Admin CRUD: Country Currencies
- Labels: area/admin, area/references, type/feature
- Accept: CountryCurrency maintainable; public reads intact.
- Tasks:
  - Controller, views
  - Policy + request specs

17) Lock down public System controllers to read-only
- Labels: area/references, type/change
- Accept: No write actions outside `/admin`.
- Tasks:
  - Remove or guard `new/create/edit/update/destroy`
  - Add redirects if paths change

### Consumer Helpers and Caching
18) Add `ref_options` and `ref_label` helpers with cache version
- Labels: area/references, type/feature
- Accept: Helpers return option arrays and labels; cache busts on change.
- Tasks:
  - Helper module
  - Versioning hook in ReferenceValue

19) Replace hardcoded selects in consumer forms
- Labels: area/ui, area/references, type/change
- Accept: All forms use helpers; no inline option lists.
- Tasks:
  - Sweep forms
  - Smoke test key flows

### Audits, Errors, CI
20) Enable audits on admin-managed models
- Labels: area/audit, type/feature, security
- Accept: Create/update/delete tracked with whodunnit.
- Tasks:
  - Add `audited` or `paper_trail`
  - Hook current_user

21) 401/403 error pages and handling
- Labels: area/security, type/feature
- Accept: Unauthorized → 401/403 pages; logs include request id.
- Tasks:
  - Views/layouts
  - Controller rescue

22) CI gates for auth/rbac/admin
- Labels: area/ci, type/chore
- Accept: GH Actions run tests, brakeman, importmap audit.
- Tasks:
  - Workflow file
  - Status badge in README

### Docs and Seeds
23) Update README and Admin Guide
- Labels: area/docs, type/docs
- Accept: New dev can bootstrap, seed, and reach admin.
- Tasks:
  - Setup, roles, seeds, login steps
  - Access model diagram link

24) Versioned seeds for references and branches
- Labels: area/data, type/chore
- Accept: Rake tasks load specific versions; idempotent.
- Tasks:
  - `refs:load[version]`, `branches:seed`
  - Cache bust after load

---

```
Title,Body,Labels,Milestone
Add Devise and scaffold auth,"Accept: Users can sign up/in/out.\nTasks: add gems, install, generate User, mailer URLs.","area/auth,type/feature","Foundation: Access Control and Administration"
Seed initial system admin,"Accept: One admin after seeds.\nTasks: seed script, README note.","area/auth,type/chore,security","Foundation: Access Control and Administration"
Require login globally,"Accept: Auth required by default.\nTasks: authenticate_user!, allowlist health/root.","area/auth,type/change","Foundation: Access Control and Administration"
Install Pundit and base policy,"Accept: Pundit wired; default deny; 403 on violation.","area/rbac,type/feature","Foundation: Access Control and Administration"
Add role enum to User,"Accept: roles with predicate helpers.\nTasks: migration, enum, backfill.","area/rbac,type/change","Foundation: Access Control and Administration"
Policy specs baseline,"Accept: base allow/deny tested.","area/rbac,type/test","Foundation: Access Control and Administration"
Create Branch model and migration,"Accept: branches table with unique code.","area/branches,type/feature","Foundation: Access Control and Administration"
Create BranchMembership (Users ↔ Branches),"Accept: many-to-many with unique pair.","area/branches,type/feature","Foundation: Access Control and Administration"
Link Parties to Branch (nullable),"Accept: parties.branch_id FK added.","area/branches,type/change","Foundation: Access Control and Administration"
Seed default branch(es),"Accept: 001 Main Office exists.","area/branches,type/chore","Foundation: Access Control and Administration"
Admin CRUD for Branches,"Accept: /admin/branches guarded and working.","area/branches,area/admin,type/feature","Foundation: Access Control and Administration"
Create /admin/system namespace,"Accept: Admin dashboard reachable.","area/admin,type/feature","Foundation: Access Control and Administration"
Admin CRUD: ReferenceLists,"Accept: Lists CRUD under admin.","area/admin,area/references,type/feature","Foundation: Access Control and Administration"
Admin CRUD: ReferenceValues,"Accept: Values CRUD under admin.","area/admin,area/references,type/feature","Foundation: Access Control and Administration"
Admin CRUD: NAICS Codes,"Accept: NAICS maintainable under admin.","area/admin,area/references,type/feature","Foundation: Access Control and Administration"
Admin CRUD: Country Currencies,"Accept: CountryCurrency maintainable.","area/admin,area/references,type/feature","Foundation: Access Control and Administration"
Lock down public System controllers to read-only,"Accept: No writes outside /admin.","area/references,type/change","Foundation: Access Control and Administration"
Add ref_options and ref_label helpers with cache,"Accept: Helpers live; cache busts on change.","area/references,type/feature","Foundation: Access Control and Administration"
Replace hardcoded selects in consumer forms,"Accept: Forms use helpers only.","area/ui,area/references,type/change","Foundation: Access Control and Administration"
Enable audits on admin-managed models,"Accept: Changes versioned with user.","area/audit,type/feature,security","Foundation: Access Control and Administration"
401/403 error pages and handling,"Accept: Dedicated pages and logs.","area/security,type/feature","Foundation: Access Control and Administration"
CI gates for auth/rbac/admin,"Accept: GH Actions run tests and scanners.","area/ci,type/chore","Foundation: Access Control and Administration"
Update README and Admin Guide,"Accept: Bootstrap and admin docs complete.","area/docs,type/docs","Foundation: Access Control and Administration"
Versioned seeds for references and branches,"Accept: Idempotent tasks with version arg.","area/data,type/chore","Foundation: Access Control and Administration"
```