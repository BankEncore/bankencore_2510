# app/models/system/naics_code.rb
class System::NaicsCode < ApplicationRecord
  self.table_name = "system_naics_codes"

  validates :year, :code, :title, presence: true
  validates :code, format: { with: /\A\d{2,6}\z/ }
  validates :code, uniqueness: { scope: :year }
  before_validation :derive_fields

  def ancestors
    parts = []
    c = code
    while c.length > 2
      c = c[0, c.length - 1]
      parts << c
    end
    System::NaicsCode.where(year: year, code: parts)
                    .order(Arel.sql("char_length(code)"))
  end

  def children
    System::NaicsCode.where(year: year)
      .where("code LIKE ? AND char_length(code) = ?", "#{code}%", code.length + 1)
      .order(:code)
  end

  def descendants
    System::NaicsCode.where(year: year)
      .where("code LIKE ? AND char_length(code) > ?", "#{code}%", code.length)
      .order(:code)
  end

  def parent
    return nil if code.length <= 2
    System::NaicsCode.find_by(year: year, code: code[0, code.length - 1])
    end
end

  private

  def derive_fields
    self.level  = code.to_s.length if code.present?
    self.sector = code.to_s[0, 2] if code.present?
    self.parent_code = code.to_s.length > 2 ? code[0, code.length - 1] : nil if code.present?
  end
