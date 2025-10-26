# lib/tasks/naics.rake
require "csv"

namespace :naics do
  # rails "naics:import[/abs/path/naics_2022.csv]"
  desc "Import NAICS CSV with headers: Code,Title,Description (assumes version=2022)"
  task :import, [ :csv_path ] => :environment do |_, args|
    path = args[:csv_path] or abort "CSV path required"
    now  = Time.current
    idx  = :index_system_naics_codes_on_version_and_code

    norm_hdr = ->(h) { h.to_s.encode("UTF-8", invalid: :replace).sub(/\A\xEF\xBB\xBF/, "").strip.downcase }
    clean_t  = ->(s) { s = s.to_s.strip; s.end_with?("T") ? s[0...-1] : s }
    parent   = ->(code) { code.length > 2 ? code[0, code.length - 1] : nil }

    scanned = kept = skipped = 0
    buf = []

    CSV.foreach(path,
      headers: true,
      header_converters: norm_hdr,
      encoding: "bom|utf-8",
      col_sep: ",",
      row_sep: :auto,          # handles CRLF and embedded newlines in quotes
      quote_char: '"'
    ) do |row|
      scanned += 1
      code = row["code"].to_s.strip
      unless code.match?(/\A\d{2,6}\z/)
        skipped += 1
        next
      end

      title = clean_t.(row["title"])
      desc  = row["description"].to_s
      desc  = nil if desc.strip.empty? || desc.strip.casecmp("null").zero?

      buf << {
        version:     "2022",
        code:        code,
        title:       title,
        description: desc,
        parent_code: parent.(code),
        level:       code.length,
        sector:      code[0, 2],
        active:      true,
        created_at:  now,
        updated_at:  now
      }
      kept += 1

      if buf.size >= 1000
        System::NaicsCode.upsert_all(buf, unique_by: idx)
        buf.clear
      end
    end

    System::NaicsCode.upsert_all(buf, unique_by: idx) if buf.any?
    puts "Scanned: #{scanned}  Kept: #{kept}  Skipped: #{skipped}"
  end
end
