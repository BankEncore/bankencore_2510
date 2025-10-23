# db/seeds/standards/country_currencies.rb
now = Time.current

# detect join FK type
cc_cols = System::CountryCurrency.columns.index_by(&:name)
ctype   = cc_cols.fetch("country_id").type # :string or :integer/:bigint

# detect country 2-letter column
code2_col = (System::Country.column_names & %w[alpha2 iso2]).first or raise "no country 2-letter column"

# currencies present?
cur_ids = System::Currency.where(code: %w[USD CAD]).pluck(:code, :id).to_h
missing = %w[USD CAD] - cur_ids.keys
raise "Seed currencies first: #{missing.join(', ')}" if missing.any?

rows =
  if ctype == :string
    # FK stores alpha2/iso2 string directly
    [
      { country_id: "US", currency_id: cur_ids["USD"], created_at: now, updated_at: now },
      { country_id: "CA", currency_id: cur_ids["CAD"], created_at: now, updated_at: now }
    ]
  else
    # FK stores numeric country PK; look up by detected code2 column
    by_code2 = System::Country.where(code2_col => %w[US CA]).pluck(code2_col, :id).to_h
    miss = %w[US CA] - by_code2.keys
    raise "Countries missing: #{miss.join(', ')}" if miss.any?
    [
      { country_id: by_code2["US"], currency_id: cur_ids["USD"], created_at: now, updated_at: now },
      { country_id: by_code2["CA"], currency_id: cur_ids["CAD"], created_at: now, updated_at: now }
    ]
  end

# pick unique index if present
idx = ActiveRecord::Base.connection
         .indexes("system_country_currencies")
         .find { |i| i.unique && i.columns.map(&:to_s) == %w[country_id currency_id] }
unique_by = idx ? idx.name.to_sym : [ :country_id, :currency_id ]

System::CountryCurrency.upsert_all(rows, unique_by: unique_by)
puts "CountryCurrencies: #{System::CountryCurrency.count} (country_id type: #{ctype}, country code col: #{code2_col})"
