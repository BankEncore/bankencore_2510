# frozen_string_literal: true

module System
  class NaicsImporter
    def self.run(path:, year:)
      require "csv"
      now  = Time.current
      cols = System::NaicsCode.column_names.map(&:to_sym)
      has_active = cols.include?(:active)

      rows = []
      CSV.foreach(path, headers: true) do |r|
        code = r["Code"].to_s.strip
        next unless code =~ /\A\d{2,6}\z/
        title = (r["Title"] || "").to_s.strip.sub(/T\z/, "")
        desc  = (r["Description"] || "").to_s.strip
        desc  = nil if desc.casecmp("null").zero?

        level  = code.length
        parent = level > 2 ? code[0, level - 1] : nil
        sector = code[0, 2]

        attrs = {
          code: code, title: title, description: desc,
          sector: sector, parent_code: parent, level: level,
          year: year, created_at: now, updated_at: now
        }
        attrs[:active] = true if has_active
        rows << attrs.slice(*cols)
      end
      raise "no rows" if rows.empty?

      System::NaicsCode.upsert_all(rows, unique_by: %i[year code])
      if has_active
        keep = rows.map { |h| h[:code] }
        System::NaicsCode.where(year: year).where.not(code: keep)
                         .update_all(active: false, updated_at: now)
      end
      rows.size
    end
  end
end
