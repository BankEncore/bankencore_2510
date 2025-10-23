# app/helpers/hours_helper.rb
module HoursHelper
  DAYS = %w[mon tue wed thu fri sat sun].freeze
  LABELS = { mon: "Mon", tue: "Tue", wed: "Wed", thu: "Thu", fri: "Fri", sat: "Sat", sun: "Sun" }.freeze

  def branch_hours_rows(branch)
    tz = ActiveSupport::TimeZone[branch.time_zone] || Time.zone
    now = tz.now
    today_key = DAYS[now.wday == 0 ? 6 : now.wday - 1] # Sun=0 -> "sun"

    rows = DAYS.map do |d|
      h = (branch.operating_hours || {})[d]
      if h.nil? || h["open"].blank? || h["close"].blank?
        { key: d, label: LABELS[d.to_sym], text: "Closed", today: (d == today_key), open_now: false }
      else
        o_s, c_s = h["open"], h["close"]  # "HH:MM"
        open_t  = tz.parse(o_s)
        close_t = tz.parse(c_s)
        text = "#{open_t.strftime('%-I:%M %p')} – #{close_t.strftime('%-I:%M %p')}"
        open_now = (d == today_key) && now.between?(open_t, close_t)
        { key: d, label: LABELS[d.to_sym], text:, today: (d == today_key), open_now: }
      end
    end

    today = rows.find { |r| r[:today] }
    { rows:, today: }
  end
end
