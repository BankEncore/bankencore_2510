# frozen_string_literal: true

require "yaml"
require "active_support/core_ext/hash/indifferent_access"

module Seeds
  module References
    module_function

    def bool(v) = ActiveModel::Type::Boolean.new.cast(v)
    def date(v) = v.present? ? Date.parse(v.to_s) : nil

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

    def upsert_value(list_id, h)
      h = h.with_indifferent_access
      rec = ::System::ReferenceValue.find_or_initialize_by(system_reference_list_id: list_id, key: h.fetch(:key))
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
      doc = YAML.load_file(path)
      unless doc.is_a?(Hash) && doc["list"].is_a?(Hash)
        puts "SKIP invalid YAML: #{path}"
        return [ 0, 0 ]
      end
      list = upsert_list(doc.fetch("list"))
      v = Array(doc["values"])
      v.each { |row| upsert_value(list.id, row) }
      [ 1, v.size ]
    rescue => e
      warn "ERROR in #{path}: #{e.class}: #{e.message}"
      raise
    end

    def run(dir: Rails.root.join("db/seeds/data/references"))
      files = Dir.glob(File.join(dir, "*.yml")).sort
      puts "Reference seed path: #{dir}"
      puts "Files: #{files.size}"
      total_lists = 0
      total_vals  = 0
      files.each do |p|
        lists, vals = load_yaml_file(p)
        total_lists += lists
        total_vals  += vals
        puts "Loaded #{File.basename(p)} -> lists:+#{lists}, values:+#{vals}"
      end
      puts "Totals -> lists: #{::System::ReferenceList.count}, values: #{::System::ReferenceValue.count}"
      puts "Session adds -> lists:+#{total_lists}, values:+#{total_vals}"
    end
  end
end

Seeds::References.run
