# app/models/payments/ach_routing.rb
module Payments
  class AchRouting < ApplicationRecord
    self.table_name = "payments_ach_routings"
    include HasPublicId

    before_validation :apply_defaults

    def to_param = public_id

    scope :q, ->(s) {
      s.present? ? where("(routing_number = :s OR customer_name ILIKE :like OR state_code = :s)", s: s, like: "%#{s}%") : all
    }
    scope :state, ->(abbrev) { abbrev.present? ? where(state_code: abbrev) : all }
    scope :active_view, -> { where(data_view_code: "1") }

    def frb_branch
      Payments::FrbDirectory.lookup(servicing_frb_number)
    end

    def routing_changed?
      new_routing_number.present? && new_routing_number != "000000000"
    end

    def flags
      pairs = []
      pairs << [ "U.S. Treasury",        "badge-primary" ]   if us_treasury
      pairs << [ "USPS Money Order",     "badge-secondary" ] if us_postal_service
      pairs << [ "Federal Reserve Bank", "badge-accent" ]    if federal_reserve_bank
      pairs << [ "On Us",                "badge-info" ]      if on_us
      pairs << [ "Special Handling",     "badge-warning" ]   if special_handling
      pairs
    end

    private

    def apply_defaults
      self.routing_number         = routing_number.to_s.rjust(9, "0")      if routing_number.present?
      self.new_routing_number     = "000000000"                            if new_routing_number.blank?
      self.servicing_frb_number   = servicing_frb_number.to_s.rjust(9, "0") if servicing_frb_number.present?

      self.record_type_code       ||= "0"  # FedACH default
      self.office_code            ||= "O"  # 0 = main office
      self.institution_status_code ||= "1" # active
      self.data_view_code         ||= "1"  # current view
      self.office_code = normalize_office_code(office_code)
    end
    def normalize_office_code(v)
      x = v.to_s.strip.upcase
      return "B" if x == "1" || x == "B"
      "O" # default + maps nil,"", "0", "O", anything else -> "O"
    end
  end
end
