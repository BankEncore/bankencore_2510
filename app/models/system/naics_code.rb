# app/models/system/naics_code.rb
class System::NaicsCode < ApplicationRecord
  self.table_name = "system_naics_codes"

  validates :year, :code, :title, presence: true
  validates :code, format: { with: /\A\d{2,6}\z/ }
  validates :code, uniqueness: { scope: :year }
  before_validation :derive_fields

  private

  def derive_fields
    self.level  = code.to_s.length if code.present?
    self.sector = code.to_s[0, 2] if code.present?
    self.parent_code = code.to_s.length > 2 ? code[0, code.length - 1] : nil if code.present?
  end
end
