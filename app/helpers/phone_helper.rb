module PhoneHelper
  def phone_tag(number, country)
    return "" if number.blank?
    p = ::Phonelib.parse(number, country)
    return ERB::Util.html_escape(number) if p.invalid?
    link_to p.international, "tel:#{p.e164}", class: "link"
  end
end
