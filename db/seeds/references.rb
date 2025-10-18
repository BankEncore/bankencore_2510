# db/seeds/references.rb

def upsert_list(h)
  h = h.with_indifferent_access
  rec = ::System::ReferenceList.find_or_initialize_by(key: h.fetch(:key))
  rec.name           = h.fetch(:name)
  rec.description    = h[:description]
  rec.schema_version = h[:schema_version]
  rec.visibility     = h[:visibility] if h[:visibility].present?
  rec.tags           = Array(h[:tags]).map(&:to_s)
  rec.save!
  rec
end

def upsert_value(list, h) # <- accept the list record, not id
  h = h.with_indifferent_access
  rec = ::System::ReferenceValue
          .find_or_initialize_by(system_reference_list_id: list.id, key: h.fetch(:key))

  # satisfy belongs_to :reference_list validation
  rec.reference_list  = list

  rec.code           = h[:code]
  rec.label          = h.fetch(:label)
  rec.short_label    = h[:short_label]
  rec.description    = h[:description]
  rec.position       = (h[:position] || 0).to_i
  rec.active         = h.key?(:active) ? bool(h[:active]) : true
  rec.effective_from = date(h[:effective_from])
  rec.effective_to   = date(h[:effective_to])
  rec.parent_id      = h[:parent_id] if h.key?(:parent_id)
  rec.metadata       = (h[:metadata] || {}).to_h
  rec.save!
  rec
end

def load_yaml_file(path)
  doc = YAML.safe_load_file(path)
  unless doc.is_a?(Hash) && doc["list"].is_a?(Hash)
    puts "SKIP invalid YAML: #{path}"
    return [0, 0]
  end

  lists_added = 0
  vals_added  = 0

  ApplicationRecord.transaction do
    list = upsert_list(doc.fetch("list"))
    lists_added = 1

    Array(doc["values"]).each do |row|
      upsert_value(list, row)         # <- pass the record
      vals_added += 1
    end
  end

  [lists_added, vals_added]
rescue => e
  warn "ERROR in #{path}: #{e.class}: #{e.message}"
  raise
end
