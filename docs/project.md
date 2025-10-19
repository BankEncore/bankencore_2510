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
