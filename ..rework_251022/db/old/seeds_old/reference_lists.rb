now = Time.current

lists = [
  { key: "phone_types", name: "Phone Types" },
  { key: "email_types", name: "Email Types" },
  { key: "address_types", name: "Address Types" }
].map { _1.merge(created_at: now, updated_at: now, active: true) }

System::ReferenceList.upsert_all(lists, unique_by: :index_system_reference_lists_on_key)

by_key = System::ReferenceList.where(key: lists.map { _1[:key] }).index_by(&:key)

values = [
  { list: "phone_types",  code: "MOBILE", name: "Mobile",  sort_index: 10 },
  { list: "phone_types",  code: "WORK",   name: "Work",    sort_index: 20 },
  { list: "email_types",  code: "WORK",   name: "Work",    sort_index: 10 },
  { list: "address_types", code: "HOME",   name: "Home",    sort_index: 10 }
].map { |v| v.merge(reference_list_id: by_key.fetch(v[:list]).id, active: true, created_at: now, updated_at: now) }

System::ReferenceValue.upsert_all(
  values.map { |v| v.except(:list) },
  unique_by: :idx_srv_on_list_code
)
puts "Reference lists: #{System::ReferenceList.count}, values: #{System::ReferenceValue.count}"
