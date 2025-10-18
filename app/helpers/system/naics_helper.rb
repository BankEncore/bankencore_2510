# app/helpers/system/naics_helper.rb
module System::NaicsHelper
  def naics_label(n) = "#{n.code}: #{n.title}"
  def naics_link(n)  = link_to naics_label(n), system_naics_code_path(n), class: "link"
end
