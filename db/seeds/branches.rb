Branch.find_or_create_by!(code: "001") do |b|
  b.name = "Main Office"
  b.status = "active"
end