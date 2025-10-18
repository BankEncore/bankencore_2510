require "roo"

path = Rails.root.join("db/seeds/data/2-6 digit_2022_Codes.xlsx")
raise "File not found: #{path}" unless File.exist?(path)

sheet = Roo::Excelx.new(path)
sheet.each_row_streaming(offset: 1) do |row|
  # Adjust if header order differs
  code  = row[0].cell_value.to_s.strip
  title = row[1].cell_value.to_s.strip
  next if code.empty?

  level  = code.length
  parent = code.length > 2 ? code[0, code.length - 1] : nil
  sector = code[0, 2]

  rec = System::NaicsCode.find_or_initialize_by(year: 2022, code: code)
  rec.title       = title
  rec.parent_code = parent
  rec.sector      = sector
  rec.level       = level
  rec.save!
end

puts "Loaded NAICS 2022 codes: #{System::NaicsCode.where(year: 2022).count}"
