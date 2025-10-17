# app/models/payments/ach_routing.rb
module Payments
  class AchRouting < ApplicationRecord
    self.table_name = "payments_ach_routings"
    include HasPublicId

    scope :q, ->(s) {
      return all if s.blank?
      where("routing_number = :s OR customer_name ILIKE :like OR state_code = :s",
            s: s, like: "%#{s}%")
    }
    scope :state, ->(abbrev) { abbrev.present? ? where(state_code: abbrev) : all }
    scope :active_view, -> { where(data_view_code: "1") }
  end
end
