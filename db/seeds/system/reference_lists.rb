# db/seeds/system/reference_lists.rb
ActiveRecord::Base.transaction do
  now = Time.current

  lists = [
    { key: "phone_types",    name: "Phone Types" },
    { key: "email_types",    name: "Email Types" },
    { key: "address_types",  name: "Address Types" },
    { key: "website_types",  name: "Website Types" },
    { key: "party_types",        name: "Party Types" },
    { key: "relationship_types", name: "Relationship Types" },
    { key: "ownership_types",    name: "Ownership Types" },
    { key: "id_kinds",           name: "Identification Kinds" },
    { key: "name_prefixes",      name: "Name Prefixes" },
    { key: "name_suffixes",      name: "Name Suffixes" },
    { key: "user_statuses",   name: "User Statuses" },
    { key: "branch_statuses", name: "Branch Statuses" },
    { key: "ach_office_codes",         name: "ACH Office Codes" },
    { key: "ach_record_type_codes",    name: "ACH Record Type Codes" },
    { key: "ach_institution_statuses", name: "ACH Institution Status Codes" },
    { key: "ach_data_view_codes",      name: "ACH Data View Codes" },
    { key: "naics_versions", name: "NAICS Versions" }
  ].map { _1.merge(created_at: now, updated_at: now) }

  System::ReferenceList.upsert_all(lists, unique_by: :index_system_reference_lists_on_key)
end

puts "Reference lists: #{System::ReferenceList.count}"
