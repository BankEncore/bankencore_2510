module Payments::AchRoutingsHelper
  US_STATES = %w[AL AK AZ AR CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY].freeze

  def hl(text, term)
    return h(text) if term.blank?
    escaped = ERB::Util.h(text.to_s)
    pattern = Regexp.new(Regexp.escape(term), Regexp::IGNORECASE)
    escaped.gsub(pattern) { |m| "<mark>#{m}</mark>" }.html_safe
  end

  FLAG_DEFS = {
    us_treasury:         [ "U.S. Treasury",        "badge-primary" ],
    usps_money_order:    [ "USPS Money Order",     "badge-info" ],
    federal_reserve_bank: [ "Federal Reserve Bank", "badge-accent" ],
    on_us:               [ "On Us",                "badge-success" ],
    special_handling:    [ "Special Handling",     "badge-warning" ]
  }.freeze

  def routing_flags_badges(routing)
    badges = FLAG_DEFS.filter_map do |attr, (label, css)|
      next unless routing.respond_to?(attr) || routing.respond_to?("#{attr}?")
      val = routing.public_send(routing.respond_to?("#{attr}?") ? "#{attr}?" : attr)
      next unless val
      content_tag(:span, label, class: "badge badge-sm #{css}")
    end
    badges.presence&.join(" ").to_s.html_safe.presence || content_tag(:span, "—", class: "opacity-50")
  end
end
