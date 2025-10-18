module Payments::AchRoutingsHelper
  US_STATES = %w[AL AK AZ AR CA CO CT DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY].freeze

  def hl(text, term)
    return h(text) if term.blank?
    escaped = ERB::Util.h(text.to_s)
    pattern = Regexp.new(Regexp.escape(term), Regexp::IGNORECASE)
    escaped.gsub(pattern) { |m| "<mark>#{m}</mark>" }.html_safe
  end
end