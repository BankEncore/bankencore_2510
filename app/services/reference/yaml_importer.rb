# app/services/reference/yaml_importer.rb
require "yaml"
module Reference
  class YamlImporter
    # Returns: { lists: 1, values: N, changed: M }
    def self.call(path:, dry: false, purge: false, verbose: false)
      new(path:, dry:, purge:, verbose:).call
    end

    def initialize(path:, dry:, purge:, verbose:)
      @path    = path
      @dry     = dry
      @purge   = purge
      @verbose = verbose
    end

    def call
      data = load_yaml!(@path)
      assert_presence!(data, "key", "values")

      key   = data.fetch("key")
      name  = data["name"] || key.split(".").last.humanize
      lists = 0
      vals  = 0
      changed = 0

      ActiveRecord::Base.transaction do
        list = upsert_list!(key:, name:, data:)
        lists += 1

        seen_codes = []

        data.fetch("values").each_with_index do |v, i|
          vals += 1
          code = fetch_str!(v, "code")
          seen_codes << code

        payload = {
        name:         fetch_str!(v, "name"),
        short_name:   v["short_name"],
        description:  v["description"],
        sort_index:   v.key?("position") ? v["position"] : i * 10, # map YAML 'position' -> DB 'sort_index'
        active:       v.key?("active") ? !!v["active"] : true,
        external_code: v["external_code"],
        metadata:     v["metadata"].is_a?(Hash) ? v["metadata"] : {},
        valid_from:   v["valid_from"],
        valid_to:     v["valid_to"]
          # NOTE: your schema does not have 'applies_to' or 'jurisdiction', so we do NOT set them
        }

          changed += upsert_value!(list:, code:, attrs: payload)
        end

        if @purge
          changed += purge_missing!(list:, keep_codes: seen_codes)
        end

        raise ActiveRecord::Rollback if @dry
      end

      { lists: lists, values: vals, changed: changed }
    end

    private

    def upsert_list!(key:, name:, data:)
      model = System::ReferenceList.find_or_initialize_by(key:)
      before = model.attributes.dup
      model.name        = name
      model.description = data["description"] if data.key?("description")
      changed = changed?(before, model)

      log "  • List #{key} #{changed ? '(update)' : '(ok)'}" if @verbose
      model.save! if changed
      model
    end

    def upsert_value!(list:, code:, attrs:)
      rv = System::ReferenceValue.find_or_initialize_by(reference_list_id: list.id, code: code)
      before = rv.attributes.slice(*assignable_keys(rv))

      assign_attrs(rv, attrs)

      if changed?(before, rv)
        log "    - #{code}  #{diff_summary(before, rv)}" if @verbose
        rv.save!
        1
      else
        0
      end
    end

    def purge_missing!(list:, keep_codes:)
      gone = System::ReferenceValue.where(reference_list_id: list.id).where.not(code: keep_codes)
      n = gone.count
      return 0 if n.zero?

      log "  • Purging #{n} value(s) not in files (#{list.key})"
      gone.delete_all
      n
    end

    def assignable_keys(rv)
    # Match your schema exactly
    allowed = %w[
        name short_name description sort_index active external_code metadata valid_from valid_to
    ]
    rv.attribute_names & allowed
    end

    def assign_attrs(rv, attrs)
    attrs.each do |k, v|
        next unless rv.has_attribute?(k.to_s)
        rv.public_send("#{k}=", v)
    end
    end

    # ------------ helpers ------------
    def load_yaml!(path)
      YAML.safe_load(File.read(path), permitted_classes: [ Date, Time ], aliases: true) || {}
    rescue Psych::SyntaxError => e
      raise "YAML syntax error in #{path}: #{e.message}"
    end

    def assert_presence!(hash, *keys)
      keys.each { |k| raise "YAML missing required key: #{k}" unless hash.key?(k) }
    end

    def fetch_str!(h, key)
      v = h[key]
      raise "Missing #{key}" if v.nil? || v.to_s.strip.empty?
      v.to_s
    end

    def changed?(before, rec)
      after = rec.attributes.slice(*before.keys)
      before != after
    end

    def diff_summary(before, rec)
      after = rec.attributes.slice(*before.keys)
      diffs = before.keys.grep_v("updated_at").select { |k| before[k] != after[k] }
      diffs.map { |k| "#{k}: #{before[k].inspect}→#{after[k].inspect}" }.join(", ")
    end

    def log(msg) = puts(msg)
  end
end
