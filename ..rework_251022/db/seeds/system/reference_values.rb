# db/seeds/system/reference_values.rb

# 1) Detect columns present on System::ReferenceValue
value_cols = System::ReferenceValue.column_names

LIST_ID_COL =
  if value_cols.include?("reference_list_id")        then :reference_list_id
  elsif value_cols.include?("system_reference_list_id") then :system_reference_list_id
  else
    raise "System::ReferenceValue missing list id column"
  end

NAME_COL = ([ :name, :title, :label ].map(&:to_s) & value_cols).first&.to_sym
raise "System::ReferenceValue missing display column (:name/:title/:label)" unless NAME_COL

HAS_SORT     = value_cols.include?("sort_index")
HAS_METADATA = value_cols.include?("metadata")
HAS_ACTIVE   = value_cols.include?("active")
HAS_KEY      = value_cols.include?("key")

# 2) Fetch list ids
LIST_KEYS = %w[
  phone_types email_types address_types website_types
  party_types relationship_types ownership_types id_kinds
  name_prefixes name_suffixes user_statuses branch_statuses
  ach_office_codes ach_record_type_codes ach_institution_statuses ach_data_view_codes
  naics_versions
]
list_ids = System::ReferenceList.where(key: LIST_KEYS).pluck(:key, :id).to_h

# 3) Row helper using only available columns
def make_row(list_id_col, list_ids, list_key, code, display, sort = 50)
  h = {
    list_id_col => list_ids.fetch(list_key),
    code: code,
    NAME_COL => display,
    created_at: Time.current,
    updated_at: Time.current
  }
  h[:key]        = code if HAS_KEY
  h[:sort_index] = sort if HAS_SORT
  h[:metadata]   = {}   if HAS_METADATA
  h[:active]     = true if HAS_ACTIVE
  h
end

vals = []

# contact
vals.concat [
  make_row(LIST_ID_COL, list_ids, "phone_types",   "MOBILE",   "Mobile",   10),
  make_row(LIST_ID_COL, list_ids, "phone_types",   "HOME",     "Home",     20),
  make_row(LIST_ID_COL, list_ids, "phone_types",   "WORK",     "Work",     30),
  make_row(LIST_ID_COL, list_ids, "phone_types",   "FAX",      "Fax",      40),

  make_row(LIST_ID_COL, list_ids, "email_types",   "PERSONAL", "Personal", 10),
  make_row(LIST_ID_COL, list_ids, "email_types",   "WORK",     "Work",     20),
  make_row(LIST_ID_COL, list_ids, "email_types",   "SUPPORT",  "Support",  30),

  make_row(LIST_ID_COL, list_ids, "address_types", "HOME",     "Home",     10),
  make_row(LIST_ID_COL, list_ids, "address_types", "MAILING",  "Mailing",  20),
  make_row(LIST_ID_COL, list_ids, "address_types", "BILLING",  "Billing",  30),
  make_row(LIST_ID_COL, list_ids, "address_types", "SHIPPING", "Shipping", 40),
  make_row(LIST_ID_COL, list_ids, "address_types", "PHYSICAL", "Physical", 50),

  make_row(LIST_ID_COL, list_ids, "website_types", "PRIMARY",  "Primary",  10),
  make_row(LIST_ID_COL, list_ids, "website_types", "SUPPORT",  "Support",  20),
  make_row(LIST_ID_COL, list_ids, "website_types", "BILLPAY",  "Bill Pay", 30)
]

# party + compliance
vals.concat [
  make_row(LIST_ID_COL, list_ids, "party_types",        "PERSON", "Person",        10),
  make_row(LIST_ID_COL, list_ids, "party_types",        "ORGANIZATION", "Organization", 20),

  make_row(LIST_ID_COL, list_ids, "relationship_types", "control_person_and_beneficial_owner", "Control Person & Beneficial Owner", 10),
  make_row(LIST_ID_COL, list_ids, "relationship_types", "control_person",                      "Control Person",                     20),
  make_row(LIST_ID_COL, list_ids, "relationship_types", "beneficial_owner",                    "Beneficial Owner",                   30),

  make_row(LIST_ID_COL, list_ids, "ownership_types", "DIRECT",   "Direct",   10),
  make_row(LIST_ID_COL, list_ids, "ownership_types", "INDIRECT", "Indirect", 20),

  make_row(LIST_ID_COL, list_ids, "id_kinds", "SSN",      "SSN",                  10),
  make_row(LIST_ID_COL, list_ids, "id_kinds", "EIN",      "EIN",                  20),
  make_row(LIST_ID_COL, list_ids, "id_kinds", "ITIN",     "ITIN",                 30),
  make_row(LIST_ID_COL, list_ids, "id_kinds", "DL",       "Driver License",       40),
  make_row(LIST_ID_COL, list_ids, "id_kinds", "PASSPORT", "Passport",             50),

  make_row(LIST_ID_COL, list_ids, "name_prefixes", "MR",  "Mr.",  10),
  make_row(LIST_ID_COL, list_ids, "name_prefixes", "MRS", "Mrs.", 20),
  make_row(LIST_ID_COL, list_ids, "name_prefixes", "MS",  "Ms.",  30),
  make_row(LIST_ID_COL, list_ids, "name_prefixes", "DR",  "Dr.",  40),

  make_row(LIST_ID_COL, list_ids, "name_suffixes", "JR",  "Jr.",  10),
  make_row(LIST_ID_COL, list_ids, "name_suffixes", "SR",  "Sr.",  20),
  make_row(LIST_ID_COL, list_ids, "name_suffixes", "II",  "II",   30),
  make_row(LIST_ID_COL, list_ids, "name_suffixes", "III", "III",  40)
]

# users + branches
vals.concat [
  make_row(LIST_ID_COL, list_ids, "user_statuses",   "active",    "Active",    10),
  make_row(LIST_ID_COL, list_ids, "user_statuses",   "suspended", "Suspended", 20),
  make_row(LIST_ID_COL, list_ids, "user_statuses",   "invited",   "Invited",   30),

  make_row(LIST_ID_COL, list_ids, "branch_statuses", "active",    "Active",    10),
  make_row(LIST_ID_COL, list_ids, "branch_statuses", "inactive",  "Inactive",  20)
]

# ACH
vals.concat [
  make_row(LIST_ID_COL, list_ids, "ach_office_codes",         "O", "Main Office", 10),
  make_row(LIST_ID_COL, list_ids, "ach_office_codes",         "B", "Branch",      20),

  make_row(LIST_ID_COL, list_ids, "ach_record_type_codes",    "0", "History", 10),
  make_row(LIST_ID_COL, list_ids, "ach_record_type_codes",    "1", "Current", 20),

  make_row(LIST_ID_COL, list_ids, "ach_institution_statuses", "1", "Receives ACH Entries", 10),
  make_row(LIST_ID_COL, list_ids, "ach_institution_statuses", "2", "Does Not Receive",     20),

  make_row(LIST_ID_COL, list_ids, "ach_data_view_codes",      "1", "Primary View",   10),
  make_row(LIST_ID_COL, list_ids, "ach_data_view_codes",      "2", "Alternate View", 20)
]

# NAICS versions
vals.concat [
  make_row(LIST_ID_COL, list_ids, "naics_versions", "2022", "NAICS 2022", 10),
  make_row(LIST_ID_COL, list_ids, "naics_versions", "2017", "NAICS 2017", 20)
]

# 4) Resolve unique_by for upsert
idx = ActiveRecord::Base.connection.indexes("system_reference_values").find do |i|
  i.unique && i.columns.map(&:to_s) == [ LIST_ID_COL.to_s, "code" ]
end
unique_by = idx ? idx.name.to_sym : [ LIST_ID_COL, :code ]

# 5) Upsert
ActiveRecord::Base.transaction do
  System::ReferenceValue.upsert_all(vals, unique_by: unique_by)
end

puts "Reference values: #{System::ReferenceValue.count} via #{LIST_ID_COL} and #{NAME_COL}"
