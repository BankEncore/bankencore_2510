# db/seeds/extras/audited_demo.rb
return unless defined?(Audited)      # skip if the gem isn't loaded
return unless ENV["SEED_EXTRAS"] == "1"  # run only when explicitly enabled

require "securerandom"

request_id = SecureRandom.uuid
admin = User.find_by(email: "admin@example.com")

Audited.store[:request_uuid] = request_id

# 1) Always create a standalone audit row for traceability
Audited.audit_class.create!(
  auditable: nil,                # standalone entry
  action:    "seed",
  audited_changes: { note: "audited_demo" },
  user:      admin,              # will link if audited uses user association
  username:  admin&.email || "seed:admin",
  comment:   "Seed audited demo entry",
  request_uuid: request_id,
  version:   0,
  created_at: Time.current
)

# 2) If Branch is audited, perform a harmless, idempotent change to generate a model-backed audit
if defined?(Branch) && Branch.new.respond_to?(:audits)
  demo = Branch.find_by(code: "999") || Branch.first
  if demo
    Audited.audit_class.as_user(admin || "seed:admin") do
      # set a deterministic note in the name to avoid drift; toggle only if missing
      base = demo.name.sub(/ \[audited\]\z/, "")
      new_name = "#{base} [audited]"
      unless demo.name == new_name
        demo.update!(name: new_name)
      end
    end
  end
end

count = Audited.audit_class.count
puts "Audited demo complete. audits=#{count} request_uuid=#{request_id}"
