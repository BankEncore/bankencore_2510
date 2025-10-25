# app/models/payments/ach_routing.rb
module Payments
  class AchRouting < ApplicationRecord
    self.table_name = "payments_ach_routings"
    include HasPublicId

    # Normalize raw attrs first, then apply defaults/derivations
    before_validation :normalize!
    before_validation :apply_defaults

    validates :routing_number, presence: true,
                               uniqueness: { case_sensitive: false },
                               format: { with: /\A\d{9}\z/ }
    validates :office_code, inclusion: { in: %w[O B], allow_nil: true }

    def to_param = public_id

    scope :q, ->(s) {
      s.present? ? where("(routing_number = :s OR customer_name ILIKE :like OR state_code = :s)",
                         s: s, like: "%#{s}%") : all
    }
    scope :state,      ->(abbrev) { abbrev.present? ? where(state_code: abbrev) : all }
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

    def normalize!
      self.routing_number       = routing_number.to_s.gsub(/\D/, "").rjust(9, "0")[-9, 9]
      self.new_routing_number   = new_routing_number.to_s.gsub(/\D/, "") if new_routing_number.present?
      self.servicing_frb_number = servicing_frb_number.to_s.gsub(/\D/, "") if servicing_frb_number.present?

      self.customer_name        = customer_name.to_s.strip.presence
      self.city                 = city.to_s.strip.presence
      self.state_code           = state_code.to_s.strip.presence&.upcase

      self.office_code          = office_code.to_s.strip.presence&.upcase
      self.record_type_code     = record_type_code.to_s.strip.presence&.upcase
      self.institution_status_code = institution_status_code.to_s.strip.presence&.upcase
      self.data_view_code       = data_view_code.to_s.strip.presence&.upcase
    end

    def apply_defaults
      self.routing_number       = routing_number.to_s.rjust(9, "0")[-9, 9]
      self.new_routing_number   = "000000000" if new_routing_number.blank?
      self.servicing_frb_number = servicing_frb_number.to_s.rjust(9, "0")[-9, 9] if servicing_frb_number.present?

      self.record_type_code     ||= "0"
      self.office_code            = normalize_office_code(office_code.presence || "O")
      self.institution_status_code ||= "1"
      self.data_view_code       ||= "1"
    end

    def normalize_office_code(val)
      v = val.to_s.strip.upcase
      return "B" if v == "1" || v == "B"
      "O"
    end
  end
end
