module Payments::AchRoutingsHelper
  def routing_changed?(r)
    r.new_routing_number.present? && r.new_routing_number != "000000000"
  end

  def routing_flags(r)
    pairs = []
    pairs << [ "U.S. Treasury",        "badge-primary" ]   if r[:us_treasury] == true
    pairs << [ "USPS Money Order",     "badge-secondary" ] if r[:us_postal_service] == true
    pairs << [ "Federal Reserve Bank", "badge-accent" ]    if r[:federal_reserve_bank] == true
    pairs << [ "On Us",                "badge-info" ]      if r[:on_us] == true
    pairs << [ "Special Handling",     "badge-warning" ]   if r[:special_handling] == true
    pairs
  end
end
