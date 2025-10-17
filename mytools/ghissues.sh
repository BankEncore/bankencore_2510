#!/usr/bin/env bash
set -euo pipefail

# Requires: gh (authed), jq
REPO="${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

# 1) Ensure labels exist
for l in domain:System domain:Parties domain:Compliance domain:Ledger \
         type:migration type:seed tests security admin api ui ops tooling rules audits backend CI; do
  gh api -X GET "repos/$REPO/labels/$(printf %s "$l" | jq -sRr @uri)" >/dev/null 2>&1 \
    || gh api -X POST "repos/$REPO/labels" -f name="$l" -f color=ededed -f description=""
done

# 2) Backlog data
read -r -d '' BACKLOG <<'JSON'
[
  {"title":"Init CI, lint, tests","body":"Set up GitHub Actions, Ruby matrix, RuboCop, RSpec. Fail on warnings. Cache bundler.","labels":["CI","tooling"],"milestone":"M0-Bootstrap & Security"},
  {"title":"RBAC skeleton","body":"Models System::User, System::Role, System::Permission; join tables; seeds for roles.","labels":["security","backend"],"milestone":"M0-Bootstrap & Security"},
  {"title":"App encryption keys","body":"Configure Active Record Encryption. Rotate keys via credentials. Document process.","labels":["security","ops"],"milestone":"M0-Bootstrap & Security"},
  {"title":"Healthcheck & base config","body":"Add /up, prod logging, timezone, UUIDs by default.","labels":["ops"],"milestone":"M0-Bootstrap & Security"},

  {"title":"Migrations: reference backbone","body":"system_reference_lists and system_reference_values with FKs, uniques, indexes.","labels":["type:migration","domain:System"],"milestone":"M1-SystemRefs"},
  {"title":"Countries and regions","body":"system_countries and system_regions; ISO 3166 schema; FKs.","labels":["type:migration","domain:System"],"milestone":"M1-SystemRefs"},
  {"title":"NAICS codes","body":"system_naics_codes with version year, title, code path.","labels":["type:migration","domain:System"],"milestone":"M1-SystemRefs"},
  {"title":"Seed data importers","body":"Idempotent seeds for ISO, regions, NAICS, enumerations used by Parties.","labels":["type:seed","domain:System"],"milestone":"M1-SystemRefs"},
  {"title":"Admin UI for references","body":"CRUD for lists/values, search, pagination, audit trail.","labels":["admin","domain:System"],"milestone":"M1-SystemRefs"},
  {"title":"Ref integrity tests","body":"RSpec for FKs, uniques, seed idempotency.","labels":["tests"],"milestone":"M1-SystemRefs"},

  {"title":"Core Party models","body":"Party, Individual, Organization; enums from references; validations.","labels":["domain:Parties","backend"],"milestone":"M2-Parties"},
  {"title":"Contact models","body":"Names, Addresses, Emails, Phones, Websites; preferred flags with partial unique indexes.","labels":["domain:Parties","type:migration"],"milestone":"M2-Parties"},
  {"title":"Relationships","body":"Party↔Party links with relationship_type, ownership %, effective dates.","labels":["domain:Parties"],"milestone":"M2-Parties"},
  {"title":"Deterministic PII encryption","body":"TIN, email, phone; deterministic lookups; supporting digests.","labels":["security","domain:Parties"],"milestone":"M2-Parties"},
  {"title":"Parties CRUD + API","body":"HTML and JSON endpoints; pagination; strong params; error shapes.","labels":["api","ui","domain:Parties"],"milestone":"M2-Parties"},
  {"title":"Parties test suite","body":"Factories, model specs, request specs; high coverage for module.","labels":["tests"],"milestone":"M2-Parties"},

  {"title":"Verification scaffolding","body":"verification_methods, verification_results, document_artifacts.","labels":["domain:Compliance"],"milestone":"M3-Compliance-Foundations"},
  {"title":"Audit/versioning","body":"Add audited or custom versions for Parties and References.","labels":["audits"],"milestone":"M3-Compliance-Foundations"},
  {"title":"Reviewer UI","body":"Queue, filters, link to Party records, status changes.","labels":["admin","domain:Compliance"],"milestone":"M3-Compliance-Foundations"},

  {"title":"GL core schema","body":"Accounts, types, org segments, periods, journals, entries, balances.","labels":["domain:Ledger","type:migration"],"milestone":"M4-Ledger-Scaffold"},
  {"title":"Posting constraints","body":"Double-entry validation, open/close period guards, trial balance check.","labels":["domain:Ledger"],"milestone":"M4-Ledger-Scaffold"},
  {"title":"Read-only admin views","body":"Accounts list, balances, journals; filters; exports.","labels":["admin","ui"],"milestone":"M4-Ledger-Scaffold"},
  {"title":"Ledger smoke tests","body":"Open/close, sample journal, TB = 0.","labels":["tests"],"milestone":"M4-Ledger-Scaffold"},

  {"title":"Transaction code rules","body":"Load TransactionCodes; map to debit/credit templates with conditions.","labels":["domain:Ledger","rules"],"milestone":"M5-Postings & Txn Codes"},
  {"title":"Posting engine","body":"Idempotent writer, reversal patterns, replay protection.","labels":["domain:Ledger","backend"],"milestone":"M5-Postings & Txn Codes"},
  {"title":"Golden-file tests","body":"Fixture scenarios for deposits, fees, reversals; diff against golden outputs.","labels":["tests"],"milestone":"M5-Postings & Txn Codes"}
]
JSON

# 3) Create issues (uses milestone titles directly)
jq -c '.[]' <<<"$BACKLOG" | while read -r item; do
  title=$(jq -r '.title' <<<"$item")
  body=$(jq -r '.body' <<<"$item")
  milestone=$(jq -r '.milestone' <<<"$item")
  mapfile -t labels < <(jq -r '.labels[]' <<<"$item")

  # build --label flags
  LABEL_ARGS=()
  for L in "${labels[@]}"; do LABEL_ARGS+=(--label "$L"); done

  gh issue create \
    --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --milestone "$milestone" \
    "${LABEL_ARGS[@]}"

  echo "Created: $title"
done
