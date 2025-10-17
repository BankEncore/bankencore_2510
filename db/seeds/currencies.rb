require "money"

def iso_num(val)
  s = val.to_s.strip
  /\A\d{1,3}\z/.match?(s) ? s : nil
end

Money::Currency.table.each_value do |c|
  System::Currency.find_or_create_by!(code: c[:iso_code].to_s[0, 3].upcase) do |r|
    r.numeric     = iso_num(c[:iso_numeric])
    r.name        = c[:name].to_s
    r.minor_units = c[:subunit_to_unit] ? Math.log10(c[:subunit_to_unit]).to_i : 0
    r.symbol      = c[:symbol].to_s
  end
end

puts "Loaded currencies: #{System::Currency.count}"
