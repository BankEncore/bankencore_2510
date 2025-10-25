now = Time.current
rows = [
  [ "USD", "US Dollar", 2 ], [ "EUR", "Euro", 2 ], [ "JPY", "Japanese Yen", 0 ], [ "GBP", "Pound Sterling", 2 ],
  [ "CNY", "Chinese Yuan", 2 ], [ "AUD", "Australian Dollar", 2 ], [ "CAD", "Canadian Dollar", 2 ],
  [ "CHF", "Swiss Franc", 2 ], [ "HKD", "Hong Kong Dollar", 2 ], [ "SGD", "Singapore Dollar", 2 ]
].map { |code, name, minor| { code:, name:, minor_units: minor, created_at: now, updated_at: now } }
System::Currency.upsert_all(rows, unique_by: [ :code ])
puts "Currencies: #{System::Currency.count}"
