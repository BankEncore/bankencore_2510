# app/models/branch.rb
# new
class Branch < ApplicationRecord
  enum status: { inactive: 0, active: 1 }

  belongs_to :country, class_name: "System::Country",
             foreign_key: :country_alpha2, primary_key: :alpha2, optional: true

  before_validation do
    self.code = code&.strip&.upcase
    self.time_zone = time_zone&.strip
    self.country_alpha2 = country_alpha2&.strip&.upcase
    self.region_code = region_code&.strip&.upcase
    self.email = email&.strip&.downcase
  end

  validates :code, presence: true, uniqueness: true, length: { maximum: 16 },
                   format: { with: /\A[A-Z0-9_-]+\z/ }
  validates :name, presence: true
  validates :time_zone, presence: true
  validates :country_alpha2, presence: true, format: { with: /\A[A-Z]{2}\z/ }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, :fax, length: { maximum: 32 }
  validates :postal_code, length: { maximum: 16 }, allow_blank: true

  # Optional: E.164 check (simple)
  validates :phone, format: { with: /\A\+?[0-9 .()-]{7,}\z/ }, allow_blank: true
end
